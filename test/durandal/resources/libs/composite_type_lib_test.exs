defmodule Durandal.CompositeTypeLibTest do
  @moduledoc false
  alias Durandal.Resources.CompositeType
  alias Durandal.Resources
  use Durandal.DataCase, async: true

  alias Durandal.ResourcesFixtures

  defp valid_attrs do
    %{
      name: "some name",
      contents: ["9438c3a0-2dd1-4ba3-aae9-bab7f2f7c931", "b8bd8449-b15d-4df2-a8e2-d1a71051555a"],
      universe_id: Durandal.GameFixtures.universe_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      contents: ["6fbaf9d1-7705-46db-a4b1-ab200b2b570a", "aead8e5d-bdf3-4cdd-816f-1b282c7a33fc"],
      universe_id: Durandal.GameFixtures.universe_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      contents: nil,
      universe_id: nil
    }
  end

  describe "composite_type" do
    alias Durandal.Resources.CompositeType

    test "composite_type_query/0 returns a query" do
      q = Resources.composite_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_composite_type/0 returns composite_type" do
      # No composite_type yet
      assert Resources.list_resources_composite_types([]) == []

      # Add a composite_type
      ResourcesFixtures.composite_type_fixture()
      assert Resources.list_resources_composite_types([]) != []
    end

    test "get_composite_type!/1 and get_composite_type/1 returns the composite_type with given id" do
      composite_type = ResourcesFixtures.composite_type_fixture()
      assert Resources.get_composite_type!(composite_type.id) == composite_type
      assert Resources.get_composite_type(composite_type.id) == composite_type
    end

    test "create_composite_type/1 with valid data creates a composite_type" do
      assert {:ok, %CompositeType{} = composite_type} =
               Resources.create_composite_type(valid_attrs())

      assert composite_type.name == "some name"
    end

    test "create_composite_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_composite_type(invalid_attrs())
    end

    test "update_composite_type/2 with valid data updates the composite_type" do
      composite_type = ResourcesFixtures.composite_type_fixture()

      assert {:ok, %CompositeType{} = composite_type} =
               Resources.update_composite_type(composite_type, update_attrs())

      assert composite_type.name == "some updated name"
    end

    test "update_composite_type/2 with invalid data returns error changeset" do
      composite_type = ResourcesFixtures.composite_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.update_composite_type(composite_type, invalid_attrs())

      assert composite_type == Resources.get_composite_type!(composite_type.id)
    end

    test "delete_composite_type/1 deletes the composite_type" do
      composite_type = ResourcesFixtures.composite_type_fixture()
      assert {:ok, %CompositeType{}} = Resources.delete_composite_type(composite_type)

      assert_raise Ecto.NoResultsError, fn ->
        Resources.get_composite_type!(composite_type.id)
      end

      assert Resources.get_composite_type(composite_type.id) == nil
    end

    test "change_composite_type/1 returns a composite_type changeset" do
      composite_type = ResourcesFixtures.composite_type_fixture()
      assert %Ecto.Changeset{} = Resources.change_composite_type(composite_type)
    end
  end
end
