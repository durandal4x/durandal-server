defmodule Durandal.SimpleTypeLibTest do
  @moduledoc false
  alias Durandal.Resources.SimpleType
  alias Durandal.Resources
  use Durandal.DataCase, async: true

  alias Durandal.ResourcesFixtures

  defp valid_attrs do
    %{
      name: "some name",
      mass: 123,
      volume: 123,
      tags: ["String one", "String two"],
      universe_id: Durandal.GameFixtures.universe_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      mass: 456,
      volume: 456,
      tags: ["String one", "String two", "String three"],
      universe_id: Durandal.GameFixtures.universe_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      mass: nil,
      volume: nil,
      tags: nil,
      universe_id: nil
    }
  end

  describe "simple_type" do
    alias Durandal.Resources.SimpleType

    test "simple_type_query/0 returns a query" do
      q = Resources.simple_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_simple_type/0 returns simple_type" do
      # No simple_type yet
      assert Resources.list_simple_types([]) == []

      # Add a simple_type
      ResourcesFixtures.simple_type_fixture()
      assert Resources.list_simple_types([]) != []
    end

    test "get_simple_type!/1 and get_simple_type/1 returns the simple_type with given id" do
      simple_type = ResourcesFixtures.simple_type_fixture()
      assert Resources.get_simple_type!(simple_type.id) == simple_type
      assert Resources.get_simple_type(simple_type.id) == simple_type
    end

    test "create_simple_type/1 with valid data creates a simple_type" do
      assert {:ok, %SimpleType{} = simple_type} =
               Resources.create_simple_type(valid_attrs())

      assert simple_type.name == "some name"
      assert simple_type.mass == 123
      assert simple_type.volume == 123
      assert simple_type.tags == ["String one", "String two"]
    end

    test "create_simple_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_simple_type(invalid_attrs())
    end

    test "update_simple_type/2 with valid data updates the simple_type" do
      simple_type = ResourcesFixtures.simple_type_fixture()

      assert {:ok, %SimpleType{} = simple_type} =
               Resources.update_simple_type(simple_type, update_attrs())

      assert simple_type.name == "some updated name"
      assert simple_type.mass == 456
      assert simple_type.volume == 456
      assert simple_type.tags == ["String one", "String two", "String three"]
    end

    test "update_simple_type/2 with invalid data returns error changeset" do
      simple_type = ResourcesFixtures.simple_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.update_simple_type(simple_type, invalid_attrs())

      assert simple_type == Resources.get_simple_type!(simple_type.id)
    end

    test "delete_simple_type/1 deletes the simple_type" do
      simple_type = ResourcesFixtures.simple_type_fixture()
      assert {:ok, %SimpleType{}} = Resources.delete_simple_type(simple_type)

      assert_raise Ecto.NoResultsError, fn ->
        Resources.get_simple_type!(simple_type.id)
      end

      assert Resources.get_simple_type(simple_type.id) == nil
    end

    test "change_simple_type/1 returns a simple_type changeset" do
      simple_type = ResourcesFixtures.simple_type_fixture()
      assert %Ecto.Changeset{} = Resources.change_simple_type(simple_type)
    end
  end
end
