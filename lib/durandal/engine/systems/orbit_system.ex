defmodule Durandal.Engine.OrbitSystem do
  @moduledoc """
  Updates object velocities based on their orbits
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Engine.{Maths, Physics}
  alias Durandal.Space

  def name(), do: "Orbit"
  def stage(), do: :physics

  @pi2 :math.pi() * 2

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(universe_id) do
    # For all objects needing to move, move them
    translations = update_system_objects(universe_id)
    update_ships(universe_id, translations)
    update_stations(universe_id, translations)
  end

  defp calculate_orbit_nest(object_map, id, acc \\ []) do
    case Map.get(object_map, id) do
      nil ->
        [id | acc]

      v ->
        calculate_orbit_nest(object_map, v, [id | acc])
    end
  end

  defp update_system_objects(universe_id) do
    # System objects need to be done a little differently as they can orbit other objects
    # this means if C orbits B and B orbits A then we need to move C by it's own orbit
    # AND by the orbit of B so it orbits relative to B still
    object_list =
      Space.list_system_objects(
        where: [universe_id: universe_id, orbiting_id: :not_nil],
        preload: [:orbiting]
      )

    object_orbit_map =
      object_list
      |> Map.new(fn object ->
        {object.id, object.orbiting_id}
      end)

    nested_orbits =
      object_orbit_map
      |> Map.new(fn {object_id, orbiting_id} ->
        {object_id, calculate_orbit_nest(object_orbit_map, orbiting_id)}
      end)

    # A map of the per-object translations
    translations =
      object_list
      |> Map.new(fn system_object ->
        radian_rotation =
          @pi2 / system_object.orbit_period * if system_object.orbit_clockwise, do: 1, else: -1

        translation =
          Physics.calculate_orbit_translation(
            system_object.position,
            system_object.orbiting.position,
            radian_rotation
          )
          |> Maths.round_list()

        {system_object.id, translation}
      end)

    # Now combine those translations with the things they orbit to
    compounded_translations =
      nested_orbits
      |> Map.new(fn {id, id_chain} ->
        combined_translation =
          id_chain
          |> Enum.reduce(translations[id] || [0, 0, 0], fn o, acc ->
            Maths.add_vector(translations[o] || [0, 0, 0], acc)
          end)

        {id, combined_translation}
      end)

    # Perform the updates
    object_list
    |> Enum.each(fn system_object ->
      if translation = compounded_translations[system_object.id] do
        new_position = Maths.add_vector(system_object.position, translation)
        {:ok, _} = Space.update_system_object(system_object, %{position: new_position})
      end
    end)

    # Send out the translations so we can use them for other objects
    compounded_translations
  end

  defp update_ships(universe_id, translations) do
    Space.list_ships(
      where: [universe_id: universe_id, orbiting_id: :not_nil, docked_with_id: :is_nil],
      preload: [:orbiting]
    )
    |> Enum.each(fn ship ->
      radian_rotation = @pi2 / ship.orbit_period * if ship.orbit_clockwise, do: 1, else: -1

      adjusted_position =
        Maths.add_vector(ship.position, translations[ship.orbiting_id] || [0, 0, 0])

      new_position =
        Physics.rotate_about_point_to_new_position(
          adjusted_position,
          ship.orbiting.position,
          radian_rotation
        )
        |> Maths.round_list()

      if new_position != ship.position do
        Space.update_ship(ship, %{position: new_position})
      end
    end)
  end

  defp update_stations(universe_id, translations) do
    Space.list_stations(
      where: [universe_id: universe_id, orbiting_id: :not_nil],
      preload: [:orbiting]
    )
    |> Enum.each(fn station ->
      radian_rotation = @pi2 / station.orbit_period * if station.orbit_clockwise, do: 1, else: -1

      adjusted_position =
        Maths.add_vector(station.position, translations[station.orbiting_id] || [0, 0, 0])

      new_position =
        Physics.rotate_about_point_to_new_position(
          adjusted_position,
          station.orbiting.position,
          radian_rotation
        )
        |> Maths.round_list()

      if new_position != station.position do
        Space.update_station(station, %{position: new_position})
      end
    end)
  end
end
