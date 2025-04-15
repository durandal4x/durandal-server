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

  # Not currently in a transfer
  defp do_execute(context, command, %{current_transfer: nil} = ship) do
    new_transfer(context, command, ship)
  end

  # In a transfer, hopefully this one!
  defp do_execute(context, _command, %{current_transfer: %{status: "in progress"}} = _ship) do
    context
  end

  defp new_transfer(context, command, ship) do
    system_object = Space.get_system_object!(command.contents["system_object_id"])
    distance = Space.calculate_distance(ship, system_object)

    {:ok, transfer} =
      Space.create_ship_transfer(%{
        universe_id: ship.universe_id,
        ship_id: ship.id,
        origin: ship.position,
        to_system_object_id: system_object.id,
        progress: command.contents["orbit_distance"],
        status: "in progress",
        started_tick: context.tick,
        distance: distance
      })

    direction = Engine.Maths.calculate_angle(system_object.position, ship.position)

    # Update the command so it has a reference of the transfer
    {:ok, _command} =
      Player.update_command(command, %{
        outcome: %{
          "transfer_id" => transfer.id,
          "start_tick" => context.tick,
          "initial_direction_from_system_object" => direction
        }
      })

    {:ok, _ship} =
      Space.update_ship(ship, %{
        orbiting_id: nil,
        docked_with_id: nil,
        current_transfer_id: transfer.id
      })

    context
  end

  def maybe_complete(context, command) do
    ship = Space.get_extended_ship(command.subject_id)
    do_maybe_complete(context, command, ship)
  end

  # Not currently in a transfer
  defp do_maybe_complete(context, command, %{current_transfer_id: nil} = ship) do
    transfer = Space.get_ship_transfer(command.outcome["transfer_id"])

    case transfer do
      %{status: "complete"} ->
        new_outcome =
          Map.merge(command.outcome || %{}, %{
            stop_tick: context.tick
          })

        {:ok, _command} =
          Player.update_command(command, %{progress: 100, outcome: new_outcome})

        {:ok, _ship} = Space.update_ship(ship, %{current_transfer_id: nil})

        # Calculate the new orbital setup for our ship as it goes around the system object
        system_object = Space.get_system_object!(transfer.to_system_object_id)

        new_position =
          Engine.Physics.apply_acceleration(
            command.outcome["initial_direction_from_system_object"],
            command.contents["orbit_distance"]
          )
          |> Engine.Maths.add_vector(system_object.position)
          |> Engine.Maths.round_list()

        {:ok, _ship} =
          Space.update_ship(ship, %{
            current_transfer_id: nil,
            position: new_position,
            velocity: system_object.velocity,
            orbiting_id: system_object.id,
            orbit_clockwise: true,
            orbit_period: 100
          })

        context

      _ ->
        context
    end
  end

  defp do_maybe_complete(context, command, _ship) do
    if command.outcome["transfer_id"] do
      # In a transfer, lets update our progress
      transfer = Space.get_ship_transfer(command.outcome["transfer_id"])

      # It's in progress, we want to update the command to show the new progress
      {:ok, _command} =
        Player.update_command(command, %{
          progress: :math.floor(transfer.progress_percentage) |> round
        })
    end

    context
  end
end
