defmodule Durandal.SystemObjectTypeLibTest do
  @moduledoc false
  alias Durandal.Types.SystemObjectType
  alias Durandal.Types
  use Durandal.DataCase, async: true

  import Durandal.GameFixtures, only: [universe_fixture: 0]
  alias Durandal.TypesFixtures

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

  describe "system_object_type" do
    alias Durandal.Types.SystemObjectType

    test "system_object_type_query/0 returns a query" do
      q = Types.system_object_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_system_object_type/0 returns system_object_type" do
      # No system_object_type yet
      assert Types.list_system_object_types([]) == []

      # Add a system_object_type
      TypesFixtures.system_object_type_fixture()
      assert Types.list_system_object_types([]) != []
    end

    test "get_system_object_type!/1 and get_system_object_type/1 returns the system_object_type with given id" do
      system_object_type = TypesFixtures.system_object_type_fixture()
      assert Types.get_system_object_type!(system_object_type.id) == system_object_type
      assert Types.get_system_object_type(system_object_type.id) == system_object_type
    end

    test "create_system_object_type/1 with valid data creates a system_object_type" do
      assert {:ok, %SystemObjectType{} = system_object_type} =
               Types.create_system_object_type(valid_attrs())

      assert system_object_type.name == "some name"
    end

    test "create_system_object_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Types.create_system_object_type(invalid_attrs())
    end

    test "update_system_object_type/2 with valid data updates the system_object_type" do
      system_object_type = TypesFixtures.system_object_type_fixture()

      assert {:ok, %SystemObjectType{} = system_object_type} =
               Types.update_system_object_type(system_object_type, update_attrs())

      assert system_object_type.name == "some updated name"
    end

    test "update_system_object_type/2 with invalid data returns error changeset" do
      system_object_type = TypesFixtures.system_object_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Types.update_system_object_type(system_object_type, invalid_attrs())

      assert system_object_type == Types.get_system_object_type!(system_object_type.id)
    end

    test "delete_object_type/1 deletes the system_object_type" do
      system_object_type = TypesFixtures.system_object_type_fixture()
      assert {:ok, %SystemObjectType{}} = Types.delete_system_object_type(system_object_type)

      assert_raise Ecto.NoResultsError, fn ->
        Types.get_system_object_type!(system_object_type.id)
      end

      assert Types.get_system_object_type(system_object_type.id) == nil
    end

    test "change_object_type/1 returns a system_object_type changeset" do
      system_object_type = TypesFixtures.system_object_type_fixture()
      assert %Ecto.Changeset{} = Types.change_system_object_type(system_object_type)
    end
  end
end
