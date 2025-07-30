defmodule Durandal.Engine.ShipLoadCargoCommand do
  @moduledoc """
  I apologise for the state of this code, it feels overly complex but at the time of writing
  it was the best I could do. Any suggestions or input on how to improve it would be most welcome.
  """
  use Durandal.Engine.CommandMacro
  alias Durandal.Resources.SimpleStationModuleInstance
  alias Durandal.Resources.CompositeStationModuleInstance
  alias Durandal.{Space, Player, Resources}

  def category(), do: "ship"
  def name(), do: "load_cargo"

  @transfer_rate 100

  @spec parse(map()) :: map() | {:error, String.t()}
  def parse(params) do
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

  # Early exit for when not docked
  defp do_execute(context, command, %{docked_with_id: nil} = ship) do
    new_outcome =
      Map.merge(command.outcome || %{}, %{
        stop_tick: context.tick
      })

    Player.update_command(command, %{progress: 100, outcome: new_outcome})

    context
    |> Engine.add_command_logs(command.id, [
      "Cancelled #{ship.id} load command as not docked with a station"
    ])
  end

  # Happy path execution
  defp do_execute(context, command, ship) do
    # Do our one transfer then update the outcome etc
    result = perform_one_transfer(command.outcome["remaining"], ship, nil)

    case result do
      nil ->
        new_outcome =
          Map.merge(command.outcome || %{}, %{
            stop_tick: context.tick
          })

        Player.update_command(command, %{progress: 100, outcome: new_outcome})

        context
        |> Engine.add_command_logs(command.id, [
          "Cancelled #{ship.id} load command as ran out of cargo to transfer"
        ])

      _ ->
        new_remaining =
          command.outcome["remaining"]
          |> Enum.map(fn [k, v] ->
            if k == result.type_id do
              [k, v - result.amount]
            else
              [k, v]
            end
          end)

        new_transferred =
          command.outcome["transferred"]
          |> Map.put(
            result.type_id,
            Map.get(command.outcome["transferred"], result.type_id, 0) + result.amount
          )

        new_total_transferred =
          new_transferred
          |> Map.values()
          |> Enum.sum()

        new_outcome =
          Map.merge(command.outcome, %{
            "remaining" => new_remaining,
            "transferred" => new_transferred
          })

        progress = calculate_progress(new_total_transferred, command.outcome["total_to_transfer"])

        if progress == 100 do
          new_outcome = Map.put(new_outcome, "stop_tick", context.tick)
          {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: progress})

          context
          |> Engine.add_command_logs(command.id, [
            "Completed cargo transfer from station #{ship.docked_with_id} to ship #{ship.id}"
          ])
        else
          {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: progress})

          context
          |> Engine.add_command_logs(command.id, [
            "Transferred #{result.amount} cargo from station #{ship.docked_with_id}, module #{result.module_id} to ship #{ship.id}"
          ])
        end
    end
  end

  # Given the list of remaining cargo to transfer, repeatedly attempt to transfer some of it
  # until you run out of cargo to transfer or are successful.
  defp perform_one_transfer([], _ship, nil) do
    nil
  end

  defp perform_one_transfer([[type_id, requested_amount] | remaining], ship, nil) do
    result = attempt_transfer(type_id, requested_amount, ship)

    case result do
      :no_transfer ->
        perform_one_transfer(remaining, ship, nil)

      {:transferred, module_id, amount} ->
        %{
          type_id: type_id,
          module_id: module_id,
          amount: amount
        }
    end
  end

  defp perform_one_transfer(_, _, acc) do
    acc
  end

  # Try to transfer some cargo, fail if the transfer doesn't take place
  defp attempt_transfer(type_id, requested_amount, ship) do
    # Get one instance of cargo
    station_cargo =
      Resources.list_all_station_resources(ship.docked_with_id, type_id)
      |> Tuple.to_list()
      |> List.flatten()
      |> List.first()

    # Minimum of the 3 limiting values
    actual_amount_to_transfer =
      Enum.min([requested_amount, station_cargo.quantity, @transfer_rate])

    case {station_cargo, actual_amount_to_transfer} do
      {_, 0} ->
        :no_transfer

      {%SimpleStationModuleInstance{}, _} ->
        # Reduce station module cargo
        {:ok, _} =
          Resources.update_simple_station_module_instance(station_cargo, %{
            quantity: station_cargo.quantity - actual_amount_to_transfer
          })

        # Increase ship cargo
        case Resources.get_simple_ship_instance_by_ship_and_type_id(ship.id, type_id) do
          nil ->
            {:ok, _} =
              Resources.create_simple_ship_instance(%{
                ship_id: ship.id,
                type_id: type_id,
                quantity: actual_amount_to_transfer,
                universe_id: ship.universe_id,
                team_id: ship.team_id
              })

          instance ->
            {:ok, _} =
              Resources.update_simple_ship_instance(instance, %{
                quantity: instance.quantity + actual_amount_to_transfer
              })
        end

        {:transferred, station_cargo.station_module_id, actual_amount_to_transfer}

      {%CompositeStationModuleInstance{}, _} ->
        # Reduce station module cargo
        {:ok, _} =
          Resources.update_composite_station_module_instance(station_cargo, %{
            quantity: station_cargo.quantity - actual_amount_to_transfer
          })

        # Increase ship cargo
        case Resources.get_composite_ship_instance_by_ship_and_type_id(ship.id, type_id) do
          nil ->
            {:ok, _} =
              Resources.create_composite_ship_instance(%{
                ship_id: ship.id,
                type_id: type_id,
                quantity: actual_amount_to_transfer,
                universe_id: ship.universe_id,
                team_id: ship.team_id
              })

          instance ->
            {:ok, _} =
              Resources.update_composite_ship_instance(instance, %{
                quantity: instance.quantity + actual_amount_to_transfer
              })
        end

        {:transferred, station_cargo.station_module_id, actual_amount_to_transfer}
    end
  end
end
