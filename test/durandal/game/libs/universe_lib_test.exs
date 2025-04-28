defmodule Durandal.UniverseLibTest do
  @moduledoc false
  alias Durandal.Game
  alias Durandal.Game.{Universe}
  use Durandal.DataCase, async: true

  alias Durandal.GameFixtures

  defp valid_attrs do
    %{
      name: "some name",
      active?: true,
      last_tick: ~U[2021-01-01 00:00:00Z],
      next_tick: ~U[2021-01-01 00:00:00Z],
      tick_schedule: "5 hours",
      tick_seconds: 18000
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      active?: false,
      last_tick: ~U[2025-05-05 00:00:00Z],
      next_tick: ~U[2025-05-05 00:00:00Z],
      tick_schedule: "5 minutes",
      tick_seconds: 24000
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      active?: nil,
      last_tick: nil,
      next_tick: nil,
      tick_schedule: nil,
      tick_seconds: nil
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

  describe "schema functions" do
    test "parse_schedule_string/1" do
      [
        {"5 hours", 18000},
        {"5 minutes", 300},
        {"5 seconds", 5},
        {"7 seconds 3 minutes and 1 hour", 3787}
      ]
      |> Enum.each(fn {input_string, expected_output} ->
        result = Universe.parse_schedule_string(input_string)

        assert result == expected_output,
          message:
            "Expected #{inspect(expected_output)}, got #{inspect(result)} for input string '#{input_string}'"
      end)
    end
  end
end
