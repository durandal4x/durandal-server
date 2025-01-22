defmodule Durandal.SystemLibTest do
  @moduledoc false
  alias Durandal.Space.System
  alias Durandal.Space
  use Durandal.DataCase, async: true

  import Durandal.GameFixtures, only: [universe_fixture: 0]
  alias Durandal.SpaceFixtures

  defp valid_attrs do
    %{
      name: "some name",
      universe_id: universe_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      universe_id: universe_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      universe_id: nil
    }
  end

  describe "system" do
    alias Durandal.Space.System

    test "system_query/0 returns a query" do
      q = Space.system_query([])
      assert %Ecto.Query{} = q
    end

    test "list_system/0 returns system" do
      # No system yet
      assert Space.list_systems([]) == []

      # Add a system
      SpaceFixtures.system_fixture()
      assert Space.list_systems([]) != []
    end

    test "get_system!/1 and get_system/1 returns the system with given id" do
      system = SpaceFixtures.system_fixture()
      assert Space.get_system!(system.id) == system
      assert Space.get_system(system.id) == system
    end

    test "create_system/1 with valid data creates a system" do
      assert {:ok, %System{} = system} =
               Space.create_system(valid_attrs())

      assert system.name == "some name"
    end

    test "create_system/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_system(invalid_attrs())
    end

    test "update_system/2 with valid data updates the system" do
      system = SpaceFixtures.system_fixture()

      assert {:ok, %System{} = system} =
               Space.update_system(system, update_attrs())

      assert system.name == "some updated name"
    end

    test "update_system/2 with invalid data returns error changeset" do
      system = SpaceFixtures.system_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_system(system, invalid_attrs())

      assert system == Space.get_system!(system.id)
    end

    test "delete_system/1 deletes the system" do
      system = SpaceFixtures.system_fixture()
      assert {:ok, %System{}} = Space.delete_system(system)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_system!(system.id)
      end

      assert Space.get_system(system.id) == nil
    end

    test "change_system/1 returns a system changeset" do
      system = SpaceFixtures.system_fixture()
      assert %Ecto.Changeset{} = Space.change_system(system)
    end
  end
end
