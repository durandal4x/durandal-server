defmodule Durandal.Engine.ShipUnloadCargoCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player, Resources}

  def category(), do: "ship"
  def name(), do: "unload_cargo"

  @transfer_rate 100

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(%{"resources" => _} = params) do
    resources =
      params["resources"]
      |> Enum.filter(fn [_, v] -> v > 0 end)

    total =
      params["resources"]
      |> Enum.map(fn [_, v] -> v end)
      |> Enum.sum()

    Map.merge(params, %{"resources" => resources, "total" => total})
  end

  def execute(context, %{outcome: nil} = command) do
    ship = Space.get_ship(command.subject_id, preload: [:cargo])

    total_to_transfer =
      command.contents["resources"]
      |> Enum.map(fn [_, v] -> v end)
      |> Enum.sum()

    outcome = %{
      "start_tick" => context.tick,
      "remaining" => command.contents["resources"],
      "total_to_transfer" => total_to_transfer,
      "transferred" => %{}
    }

    {:ok, command} = Player.update_command(command, %{outcome: outcome})

    do_execute(context, command, ship)
  end

  def execute(context, command) do
    ship = Space.get_ship(command.subject_id, preload: [:cargo])
    do_execute(context, command, ship)
  end

  defp do_execute(context, command, %{docked_with_id: nil} = ship) do
    new_outcome =
      Map.merge(command.outcome || %{}, %{
        stop_tick: context.tick
      })

    Player.update_command(command, %{progress: 100, outcome: new_outcome})

    context
    |> Engine.add_command_logs(command.id, [
      "Cancelled #{ship.id} unload command as not docked with a station"
    ])
  end

  defp do_execute(context, command, ship) do
    ship_cargo_quantities =
      (ship.simple_cargo ++ ship.composite_cargo)
      |> Map.new(fn c -> {c.type_id, c.quantity} end)

    {halt_reason, to_transfer} =
      reduce_transfer(command.outcome["remaining"], ship_cargo_quantities)

    # Based on this we want to update the cargo for the ship
    # we tag if it is simple or composite at the same time
    transferred =
      (ship.simple_cargo ++ ship.composite_cargo)
      |> Enum.filter(fn c -> Map.has_key?(to_transfer, c.type_id) end)
      |> Enum.map(fn
        %Resources.SimpleShipInstance{} = instance ->
          amount = to_transfer[instance.type_id]

          {:ok, _} =
            Resources.update_simple_ship_instance(instance, %{
              quantity: instance.quantity - amount
            })

          {instance.type_id, amount, :simple}

        %Resources.CompositeShipInstance{} = instance ->
          amount = to_transfer[instance.type_id]

          {:ok, _} =
            Resources.update_composite_ship_instance(instance, %{
              quantity: instance.quantity - amount
            })

          {instance.type_id, amount, :composite}
      end)

    # And the cargo for the station we just pick a random module since we're currently
    # not handling module behaviours at all
    # TODO: Make it so we only transfer to cargo modules
    # Start by getting the existing instances so we know if we need to create a new one or update an old one
    [module] = Space.list_station_modules(where: [station_id: ship.docked_with_id], limit: 1)

    instances =
      [
        Resources.list_simple_station_module_instances(
          where: [type_id: Map.keys(to_transfer), station_module_id: module.id]
        ),
        Resources.list_composite_station_module_instances(
          where: [type_id: Map.keys(to_transfer), station_module_id: module.id]
        )
      ]
      |> List.flatten()
      |> Map.new(fn instance -> {instance.type_id, instance} end)

    transferred
    |> Enum.each(fn
      {type_id, amount, :simple} ->
        if existing = instances[type_id] do
          {:ok, _} =
            Resources.update_simple_station_module_instance(existing, %{
              quantity: existing.quantity + amount
            })
        else
          {:ok, _} =
            Resources.create_simple_station_module_instance(%{
              type_id: type_id,
              station_module_id: module.id,
              quantity: amount,
              universe_id: ship.universe_id,
              team_id: ship.team_id
            })
        end

      {type_id, amount, :composite} ->
        if existing = instances[type_id] do
          {:ok, _} =
            Resources.update_composite_station_module_instance(existing, %{
              quantity: existing.quantity + amount
            })
        else
          {:ok, _} =
            Resources.create_composite_station_module_instance(%{
              type_id: type_id,
              station_module_id: module.id,
              quantity: amount,
              universe_id: ship.universe_id,
              team_id: ship.team_id
            })
        end
    end)

    transferred_lookup =
      transferred
      |> Map.new(fn {k, v, _} -> {k, v} end)

    new_remaining =
      command.outcome["remaining"]
      |> Enum.map(fn [k, v] ->
        [k, v - Map.get(transferred_lookup, k, 0)]
      end)

    new_outcome_transferred =
      Map.merge(command.outcome["transferred"], transferred_lookup, fn _k, a, b -> a + b end)

    new_total_transferred =
      new_outcome_transferred
      |> Map.values()
      |> Enum.sum()

    new_outcome =
      Map.merge(command.outcome, %{
        "remaining" => new_remaining,
        "transferred" => new_outcome_transferred
      })

    progress = calculate_progress(new_total_transferred, command.outcome["total_to_transfer"])

    cond do
      halt_reason == :no_more_cargo ->
        # No more cargo on ship to unload, it's done
        new_outcome = Map.put(new_outcome, "stop_tick", context.tick)
        {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: 100})

        context
        |> Engine.add_command_logs(command.id, [
          "Completed cargo transfer from ship #{ship.id} to station #{ship.docked_with_id}, module #{module.id}, stopped early as no more cargo on ship"
        ])

      progress == 100 ->
        # Cargo transferred
        new_outcome = Map.put(new_outcome, "stop_tick", context.tick)
        {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: progress})

        context
        |> Engine.add_command_logs(command.id, [
          "Completed cargo transfer from ship #{ship.id} to station #{ship.docked_with_id}, module #{module.id}"
        ])

      true ->
        # Still in progress
        {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: progress})

        context
        |> Engine.add_command_logs(command.id, [
          "Transferred cargo from ship #{ship.id} to station #{ship.docked_with_id}, module #{module.id}"
        ])
    end
  end

  defp reduce_transfer(remaining, ship_cargo_quantity) do
    reduce_transfer(remaining, ship_cargo_quantity, %{}, @transfer_rate)
  end

  defp reduce_transfer([], _ship_cargo_quantity, to_transfer, _transfer_limit) do
    {:no_more_cargo, to_transfer}
  end

  defp reduce_transfer(_, _ship_cargo_quantity, to_transfer, 0), do: {:reached_limit, to_transfer}

  defp reduce_transfer(
         [[type_id, res_count] | remaining],
         ship_cargo_quantity,
         to_transfer,
         transfer_limit
       ) do
    # The amount we transfer is the minimum of:
    # - the amount we can transfer (cargo in our hold)
    # - the amount we want to transfer (cargo remaining in the command)
    # - the amount able to be transferred per tick
    actual_amount = Enum.min([res_count, ship_cargo_quantity[type_id], transfer_limit])

    new_ship_cargo =
      Map.put(ship_cargo_quantity, type_id, ship_cargo_quantity[type_id] - actual_amount)

    # We do the Map.get in case we transferred some of this cargo last tick
    new_to_transfer =
      Map.put(to_transfer, type_id, Map.get(to_transfer, type_id, 0) + actual_amount)

    # And now we recurse
    reduce_transfer(remaining, new_ship_cargo, new_to_transfer, transfer_limit - actual_amount)
  end
end
