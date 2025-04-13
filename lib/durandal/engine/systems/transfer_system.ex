defmodule Durandal.Engine.TransferSystem do
  @moduledoc """
  Move objects transferring between different locations
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Space

  def name(), do: "Transfer"
  def stage(), do: :transfer

  @spec execute(map()) :: map()
  def execute(%{universe_id: universe_id} = context) do
    # For all objects needing to move, move them
    ships = update_ships(universe_id)
    # update_stations(universe_id)
    # update_system_objects(universe_id)

    Engine.add_systems_logs(context, name(), %{ships: ships})
  end

  defp update_ships(universe_id) do
    Space.list_ships(
      where: [universe_id: universe_id, transferring?: true, docked_with_id: :is_nil],
      preload: [:transfer_with_destination, :type]
    )
    |> Enum.map(fn %{current_transfer: ship_transfer} = ship ->
      remaining = ship_transfer.distance - ship_transfer.progress

      if remaining < ship.type.acceleration do
        complete_transfer(ship)
        {:complete, ship.id}
      else
        progress_transfer(ship)
        {:progress, ship.id}
      end
    end)
    |> Enum.group_by(fn {key, _} -> key end, fn {_, value} -> value end)
  end

  defp complete_transfer(%{current_transfer: ship_transfer} = ship) do
    destination = ship_transfer.to_station || ship_transfer.to_system_object

    {:ok, _} =
      Space.update_ship(ship, %{position: destination.position, current_transfer_id: nil})

    {:ok, _} =
      Space.update_ship_transfer(ship_transfer, %{
        progress: ship_transfer.distance,
        status: "complete"
      })
  end

  defp progress_transfer(%{current_transfer: ship_transfer} = ship) do
    # TODO: Update the ship velocity based on the acceleration and use that instead
    new_progress = ship_transfer.progress + ship.type.acceleration
    progress_percentage = new_progress / ship_transfer.distance

    destination = ship_transfer.to_station || ship_transfer.to_system_object

    new_position =
      Space.calculate_midpoint(ship_transfer.origin, destination.position, progress_percentage)

    {:ok, _} = Space.update_ship(ship, %{position: new_position})
    {:ok, _} = Space.update_ship_transfer(ship_transfer, %{progress: new_progress})
  end

  # defp update_system_objects(universe_id) do
  #   Space.list_system_objects(where: [universe_id: universe_id, orbiting_id: :is_nil])
  #   |> Enum.each(fn system_object ->
  #     new_position = Maths.sum_vectors(system_object.position, system_object.velocity)

  #     if new_position != system_object.position do
  #       Space.update_system_object(system_object, %{position: new_position})
  #     end
  #   end)
  # end

  # defp update_stations(universe_id) do
  #   Space.list_stations(where: [universe_id: universe_id, orbiting_id: :is_nil])
  #   |> Enum.each(fn station ->
  #     new_position = Maths.sum_vectors(station.position, station.velocity)

  #     if new_position != station.position do
  #       Space.update_station(station, %{position: new_position})
  #     end
  #   end)
  # end
end
