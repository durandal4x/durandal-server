defmodule Durandal.ColonyModuleLibTest do
  @moduledoc false
  alias Durandal.Space.ColonyModule
  alias Durandal.Space
  use Durandal.DataCase, async: true

  import Durandal.SpaceFixtures, only: [colony_fixture: 0, colony_module_fixture: 0]
  import Durandal.TypesFixtures, only: [colony_module_type_fixture: 0]

  defp valid_attrs do
    %{
      colony_id: colony_fixture().id,
      type_id: colony_module_type_fixture().id
    }
  end

  defp update_attrs do
    %{
      colony_id: colony_fixture().id,
      type_id: colony_module_type_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      colony_id: nil,
      type_id: nil
    }
  end

  describe "colony_module" do
    alias Durandal.Space.ColonyModule

    test "colony_module_query/0 returns a query" do
      q = Space.colony_module_query([])
      assert %Ecto.Query{} = q
    end

    test "list_colony_module/0 returns colony_module" do
      # No colony_module yet
      assert Space.list_colony_modules([]) == []

      # Add a colony_module
      colony_module_fixture()
      assert Space.list_colony_modules([]) != []
    end

    test "get_colony_module!/1 and get_colony_module/1 returns the colony_module with given id" do
      colony_module = colony_module_fixture()
      assert Space.get_colony_module!(colony_module.id) == colony_module
      assert Space.get_colony_module(colony_module.id) == colony_module
    end

    test "create_colony_module/1 with valid data creates a colony_module" do
      assert {:ok, %ColonyModule{} = _colony_module} =
               Space.create_colony_module(valid_attrs())
    end

    test "create_colony_module/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_colony_module(invalid_attrs())
    end

    test "update_colony_module/2 with valid data updates the colony_module" do
      colony_module = colony_module_fixture()

      assert {:ok, %ColonyModule{} = _colony_module} =
               Space.update_colony_module(colony_module, update_attrs())
    end

    test "update_colony_module/2 with invalid data returns error changeset" do
      colony_module = colony_module_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_colony_module(colony_module, invalid_attrs())

      assert colony_module == Space.get_colony_module!(colony_module.id)
    end

    test "delete_colony_module/1 deletes the colony_module" do
      colony_module = colony_module_fixture()
      assert {:ok, %ColonyModule{}} = Space.delete_colony_module(colony_module)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_colony_module!(colony_module.id)
      end

      assert Space.get_colony_module(colony_module.id) == nil
    end

    test "change_colony_module/1 returns a colony_module changeset" do
      colony_module = colony_module_fixture()
      assert %Ecto.Changeset{} = Space.change_colony_module(colony_module)
    end
  end
end
