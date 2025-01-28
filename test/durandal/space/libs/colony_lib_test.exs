defmodule Durandal.ColonyLibTest do
  @moduledoc false
  alias Durandal.Space.Colony
  alias Durandal.Space
  use Durandal.DataCase, async: true

  alias Durandal.SpaceFixtures
  import Durandal.PlayerFixtures, only: [team_fixture: 0]

  defp valid_attrs do
    %{
      name: "some name",
      team_id: team_fixture().id,
      position: [123, 456]
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      team_id: team_fixture().id,
      position: [123, 456, 789]
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      team_id: nil,
      position: nil
    }
  end

  describe "colony" do
    alias Durandal.Space.Colony

    test "colony_query/0 returns a query" do
      q = Space.colony_query([])
      assert %Ecto.Query{} = q
    end

    test "list_colony/0 returns colony" do
      # No colony yet
      assert Space.list_colonies([]) == []

      # Add a colony
      SpaceFixtures.colony_fixture()
      assert Space.list_colonies([]) != []
    end

    test "get_colony!/1 and get_colony/1 returns the colony with given id" do
      colony = SpaceFixtures.colony_fixture()
      assert Space.get_colony!(colony.id) == colony
      assert Space.get_colony(colony.id) == colony
    end

    test "create_colony/1 with valid data creates a colony" do
      assert {:ok, %Colony{} = colony} =
               Space.create_colony(valid_attrs())

      assert colony.name == "some name"
      assert colony.position == [123, 456]
    end

    test "create_colony/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_colony(invalid_attrs())
    end

    test "update_colony/2 with valid data updates the colony" do
      colony = SpaceFixtures.colony_fixture()

      assert {:ok, %Colony{} = colony} =
               Space.update_colony(colony, update_attrs())

      assert colony.name == "some updated name"
      assert colony.position == [123, 456, 789]
    end

    test "update_colony/2 with invalid data returns error changeset" do
      colony = SpaceFixtures.colony_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_colony(colony, invalid_attrs())

      assert colony == Space.get_colony!(colony.id)
    end

    test "delete_colony/1 deletes the colony" do
      colony = SpaceFixtures.colony_fixture()
      assert {:ok, %Colony{}} = Space.delete_colony(colony)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_colony!(colony.id)
      end

      assert Space.get_colony(colony.id) == nil
    end

    test "change_colony/1 returns a colony changeset" do
      colony = SpaceFixtures.colony_fixture()
      assert %Ecto.Changeset{} = Space.change_colony(colony)
    end
  end
end
