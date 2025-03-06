defmodule Durandal.ShipLibTest do
  @moduledoc false
  alias Durandal.Space.Ship
  alias Durandal.Space
  use Durandal.DataCase, async: true

  alias Durandal.SpaceFixtures
  import Durandal.GameFixtures, only: [universe_fixture: 0]
  import Durandal.PlayerFixtures, only: [team_fixture: 0]
  import Durandal.TypesFixtures, only: [ship_type_fixture: 0]

  defp valid_attrs do
    %{
      name: "some name",
      team_id: team_fixture().id,
      type_id: ship_type_fixture().id,
      system_id: SpaceFixtures.system_fixture().id,
      universe_id: universe_fixture().id,
      position: [123, 456],
      velocity: [123, 456],
      orbiting_id: nil,
      orbit_clockwise: true,
      orbit_period: 123,
      build_progress: 123,
      health: 123
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      team_id: team_fixture().id,
      type_id: ship_type_fixture().id,
      system_id: SpaceFixtures.system_fixture().id,
      universe_id: universe_fixture().id,
      position: [123, 456, 789],
      velocity: [123, 456, 789],
      orbiting_id: nil,
      orbit_clockwise: false,
      orbit_period: 456,
      build_progress: 456,
      health: 456
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      team_id: nil,
      type_id: nil,
      system_id: nil,
      universe_id: nil,
      position: nil,
      velocity: nil,
      orbiting_id: nil,
      orbit_clockwise: nil,
      orbit_period: nil,
      build_progress: nil,
      health: nil
    }
  end

  describe "ship" do
    alias Durandal.Space.Ship

    test "ship_query/0 returns a query" do
      q = Space.ship_query([])
      assert %Ecto.Query{} = q
    end

    test "list_ship/0 returns ship" do
      # No ship yet
      assert Space.list_ships([]) == []

      # Add a ship
      SpaceFixtures.ship_fixture()
      assert Space.list_ships([]) != []
    end

    test "get_ship!/1 and get_ship/1 returns the ship with given id" do
      ship = SpaceFixtures.ship_fixture()
      assert Space.get_ship!(ship.id) == ship
      assert Space.get_ship(ship.id) == ship
    end

    test "create_ship/1 with valid data creates a ship" do
      assert {:ok, %Ship{} = ship} =
               Space.create_ship(valid_attrs())

      assert ship.name == "some name"
      assert ship.position == [123, 456]
      assert ship.velocity == [123, 456]
      assert ship.orbit_period == 123
      assert ship.build_progress == 123
      assert ship.health == 123
    end

    test "create_ship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_ship(invalid_attrs())
    end

    test "update_ship/2 with valid data updates the ship" do
      ship = SpaceFixtures.ship_fixture()

      assert {:ok, %Ship{} = ship} =
               Space.update_ship(ship, update_attrs())

      assert ship.name == "some updated name"
      assert ship.position == [123, 456, 789]
      assert ship.velocity == [123, 456, 789]
      assert ship.orbit_period == 456
      assert ship.build_progress == 456
      assert ship.health == 456
    end

    test "update_ship/2 with invalid data returns error changeset" do
      ship = SpaceFixtures.ship_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_ship(ship, invalid_attrs())

      assert ship == Space.get_ship!(ship.id)
    end

    test "delete_ship/1 deletes the ship" do
      ship = SpaceFixtures.ship_fixture()
      assert {:ok, %Ship{}} = Space.delete_ship(ship)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_ship!(ship.id)
      end

      assert Space.get_ship(ship.id) == nil
    end

    test "change_ship/1 returns a ship changeset" do
      ship = SpaceFixtures.ship_fixture()
      assert %Ecto.Changeset{} = Space.change_ship(ship)
    end
  end
end
