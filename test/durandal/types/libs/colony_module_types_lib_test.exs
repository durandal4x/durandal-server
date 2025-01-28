defmodule Durandal.ColonyModuleTypeLibTest do
  @moduledoc false
  alias Durandal.Types.ColonyModuleType
  alias Durandal.Types
  use Durandal.DataCase, async: true

  alias Durandal.TypesFixtures

  defp valid_attrs do
    %{
      name: "some name"
    }
  end

  defp update_attrs do
    %{
      name: "some updated name"
    }
  end

  defp invalid_attrs do
    %{
      name: nil
    }
  end

  describe "colony_module_types" do
    alias Durandal.Types.ColonyModuleType

    test "colony_module_types_query/0 returns a query" do
      q = Types.colony_module_types_query([])
      assert %Ecto.Query{} = q
    end

    test "list_colony_module_types/0 returns colony_module_types" do
      # No colony_module_types yet
      assert Types.list_colony_module_types([]) == []

      # Add a colony_module_types
      TypesFixtures.colony_module_type_fixture()
      assert Types.list_colony_module_types([]) != []
    end

    test "get_colony_module_types!/1 and get_colony_module_types/1 returns the colony_module_types with given id" do
      colony_module_types = TypesFixtures.colony_module_type_fixture()
      assert Types.get_colony_module_types!(colony_module_types.id) == colony_module_types
      assert Types.get_colony_module_types(colony_module_types.id) == colony_module_types
    end

    test "create_colony_module_types/1 with valid data creates a colony_module_types" do
      assert {:ok, %ColonyModuleType{} = colony_module_types} =
               Types.create_colony_module_types(valid_attrs())

      assert colony_module_types.name == "some name"
    end

    test "create_colony_module_types/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Types.create_colony_module_types(invalid_attrs())
    end

    test "update_colony_module_types/2 with valid data updates the colony_module_types" do
      colony_module_types = TypesFixtures.colony_module_type_fixture()

      assert {:ok, %ColonyModuleType{} = colony_module_types} =
               Types.update_colony_module_types(colony_module_types, update_attrs())

      assert colony_module_types.name == "some updated name"
    end

    test "update_colony_module_types/2 with invalid data returns error changeset" do
      colony_module_types = TypesFixtures.colony_module_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Types.update_colony_module_types(colony_module_types, invalid_attrs())

      assert colony_module_types == Types.get_colony_module_types!(colony_module_types.id)
    end

    test "delete_colony_module_types/1 deletes the colony_module_types" do
      colony_module_types = TypesFixtures.colony_module_type_fixture()
      assert {:ok, %ColonyModuleType{}} = Types.delete_colony_module_types(colony_module_types)

      assert_raise Ecto.NoResultsError, fn ->
        Types.get_colony_module_types!(colony_module_types.id)
      end

      assert Types.get_colony_module_types(colony_module_types.id) == nil
    end

    test "change_colony_module_types/1 returns a colony_module_types changeset" do
      colony_module_types = TypesFixtures.colony_module_type_fixture()
      assert %Ecto.Changeset{} = Types.change_colony_module_types(colony_module_types)
    end
  end
end
