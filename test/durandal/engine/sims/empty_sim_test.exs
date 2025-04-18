defmodule Durandal.Engine.EmptySimTest do
  use Durandal.SimCase
  alias Durandal.{Space, Player, Types}

  test "tests the creation and execution of an empty scenario from file" do
    universe = start_universe("empty", [])

    pid = Durandal.Game.UniverseLib.get_game_supervisor_pid(universe.id)
    assert is_pid(pid)

    assert Space.list_systems(where: [universe_id: universe.id]) |> Enum.empty?()
    assert Player.list_teams(where: [universe_id: universe.id]) |> Enum.empty?()

    assert Types.list_ship_types(where: [universe_id: universe.id]) |> Enum.empty?()
    assert Types.list_system_object_types(where: [universe_id: universe.id]) |> Enum.empty?()
    assert Types.list_station_module_types(where: [universe_id: universe.id]) |> Enum.empty?()

    tear_down(universe.id)
  end

  test "tests the creation and execution of an empty scenario from struct" do
    universe =
      start_universe(
        %{
          "systems" => [],
          "ship_types" => [],
          "station_module_types" => [],
          "system_object_types" => [],
          "teams" => []
        },
        []
      )

    pid = Durandal.Game.UniverseLib.get_game_supervisor_pid(universe.id)
    assert is_pid(pid)

    assert Space.list_systems(where: [universe_id: universe.id]) |> Enum.empty?()
    assert Player.list_teams(where: [universe_id: universe.id]) |> Enum.empty?()

    assert Types.list_ship_types(where: [universe_id: universe.id]) |> Enum.empty?()
    assert Types.list_system_object_types(where: [universe_id: universe.id]) |> Enum.empty?()
    assert Types.list_station_module_types(where: [universe_id: universe.id]) |> Enum.empty?()

    tear_down(universe.id)
  end
end
