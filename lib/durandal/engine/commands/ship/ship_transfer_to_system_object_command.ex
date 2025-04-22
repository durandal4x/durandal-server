defmodule Durandal.Engine.ShipTransferToSystemObjectCommand do
  @moduledoc """

  """
  use Durandal.Engine.CommandMacro
  alias Durandal.{Space, Player}

  def category(), do: "ship"
  def name(), do: "transfer_to_system_object"

  @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
  def parse(params) do
    params
  end

  def execute(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_execute(context, command, ship)
  end

  # In a transfer, hopefully this one!
  defp do_execute(context, %{outcome: %{"transfer" => _transfer}} = command, ship) do
    context
    |> do_transfer(command, ship)
  end

  # Current command does not have transfer data, we need to make a new one
  defp do_execute(context, command, ship) do
    {context, command, ship} = new_transfer(context, command, ship)
    do_transfer(context, command, ship)
  end

  defp new_transfer(context, command, ship) do
    system_object = Space.get_system_object!(command.contents["system_object_id"])
    distance = Space.calculate_distance(ship, system_object)
    direction = Engine.Maths.calculate_angle(system_object.position, ship.position)

    transfer = %{
      "origin" => ship.position,
      "distance" => distance,
      "progress" => 0,
      "initial_direction_from_system_object" => direction
    }

    # Update the command so it has a reference of the transfer
    {:ok, command} =
      Player.update_command(command, %{
        outcome: %{
          "transfer" => transfer,
          "start_tick" => context.tick
        }
      })

    # Ship must be made to no longer be docked or orbiting
    {:ok, ship} =
      Space.update_ship(ship, %{
        orbiting_id: nil,
        docked_with_id: nil
      })

    # Need to get the extended ship
    ship = Space.get_extended_ship(ship.id)

    {context, command, ship}
  end

  defp do_transfer(context, %{outcome: %{"transfer" => transfer}} = command, ship) do
    remaining = transfer["distance"] - transfer["progress"] - command.contents["orbit_distance"]

    cond do
      remaining <= 0 ->
        complete_transfer(context, command, ship)

      remaining < ship.type.acceleration ->
        partial_progress_transfer(context, command, ship)

      true ->
        progress_transfer(context, command, ship)
    end
  end

  # Transfer completed, stop the ship velocity
  defp complete_transfer(context, %{outcome: %{"transfer" => transfer}} = command, ship) do
    system_object = Space.get_system_object!(command.contents["system_object_id"])

    new_position =
      Engine.Physics.apply_acceleration(
        transfer["initial_direction_from_system_object"],
        command.contents["orbit_distance"]
      )
      |> Engine.Maths.add_vector(system_object.position)
      |> Engine.Maths.round_list()

    new_outcome =
      Map.merge(command.outcome || %{}, %{
        stop_tick: context.tick
      })

    {:ok, _command} =
      Player.update_command(command, %{progress: 100, outcome: new_outcome})

    {:ok, _ship} =
      Space.update_ship(ship, %{
        position: new_position,
        velocity: system_object.velocity,
        orbiting_id: system_object.id,
        orbit_clockwise: true,
        orbit_period: 100
      })

    context
    |> Engine.add_command_logs(command.id, ["Completed transfer of #{ship.id}"])
  end

  # Transfer nearly completed, move just enough we can stop next time
  defp partial_progress_transfer(context, %{outcome: %{"transfer" => transfer}} = command, ship) do
    system_object = Space.get_system_object!(command.contents["system_object_id"])

    new_position =
      Engine.Physics.apply_acceleration(
        transfer["initial_direction_from_system_object"],
        command.contents["orbit_distance"]
      )
      |> Engine.Maths.add_vector(system_object.position)
      |> Engine.Maths.round_list()

    velocity = Engine.Maths.sub_vector(new_position, ship.position)

    {:ok, _} = Space.update_ship(ship, %{velocity: velocity})

    new_outcome =
      command.outcome
      |> put_in(~w(transfer progress), transfer["distance"])

    # We set it to 99 because if set to 100 it means the command is completed
    {:ok, _} = Player.update_command(command, %{outcome: new_outcome, progress: 99})

    context
    |> Engine.add_command_logs(command.id, ["Nearly completed transfer of #{ship.id}"])
  end

  # Standard progression of transfer
  defp progress_transfer(context, %{outcome: %{"transfer" => transfer}} = command, ship) do
    # TODO: Update the ship velocity based on the acceleration and use that instead
    new_progress = (transfer["progress"] || 0) + ship.type.acceleration
    progress_percentage = new_progress / transfer["distance"]
    system_object = Space.get_system_object!(command.contents["system_object_id"])

    new_position =
      Space.calculate_midpoint(transfer["origin"], system_object.position, progress_percentage)

    velocity = Engine.Maths.sub_vector(new_position, ship.position)

    {:ok, _} = Space.update_ship(ship, %{velocity: velocity})

    new_outcome =
      command.outcome
      |> put_in(~w(transfer progress), new_progress)

    progress_percentage_int = (progress_percentage * 100) |> :math.floor() |> round()

    {:ok, _} =
      Player.update_command(command, %{outcome: new_outcome, progress: progress_percentage_int})

    context
    |> Engine.add_command_logs(command.id, ["Progressed transfer of #{ship.id}"])
  end
end
