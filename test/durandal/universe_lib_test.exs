defmodule Durandal.UniverseLibTest do
  @moduledoc false
  alias Durandal.Game.Universe
  alias Durandal.Game
  use Durandal.DataCase, async: true

  alias Durandal.GameFixtures

  defp valid_attrs do
    %{
      name: "some name",
      active?: true
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      active?: false
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      active?: nil
    }
  end

  describe "universe" do
    alias Durandal.Game.Universe

    test "universe_query/0 returns a query" do
      q = Game.universe_query([])
      assert %Ecto.Query{} = q
    end

    test "list_universe/0 returns universe" do
      # No universe yet
      assert Game.list_universes([]) == []

      # Add a universe
      GameFixtures.universe_fixture()
      assert Game.list_universes([]) != []
    end

    test "get_universe!/1 and get_universe/1 returns the universe with given id" do
      universe = GameFixtures.universe_fixture()
      assert Game.get_universe!(universe.id) == universe
      assert Game.get_universe(universe.id) == universe
    end

    test "create_universe/1 with valid data creates a universe" do
      assert {:ok, %Universe{} = universe} =
               Game.create_universe(valid_attrs())

      assert universe.name == "some name"
    end

    test "create_universe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_universe(invalid_attrs())
    end

    test "update_universe/2 with valid data updates the universe" do
      universe = GameFixtures.universe_fixture()

      assert {:ok, %Universe{} = universe} =
               Game.update_universe(universe, update_attrs())

      assert universe.name == "some updated name"
    end

    test "update_universe/2 with invalid data returns error changeset" do
      universe = GameFixtures.universe_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_universe(universe, invalid_attrs())

      assert universe == Game.get_universe!(universe.id)
    end

    test "delete_universe/1 deletes the universe" do
      universe = GameFixtures.universe_fixture()
      assert {:ok, %Universe{}} = Game.delete_universe(universe)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_universe!(universe.id)
      end

      assert Game.get_universe(universe.id) == nil
    end

    test "change_universe/1 returns a universe changeset" do
      universe = GameFixtures.universe_fixture()
      assert %Ecto.Changeset{} = Game.change_universe(universe)
    end
  end
end
