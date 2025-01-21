defmodule Durandal.ObjectLibTest do
  @moduledoc false
  alias Durandal.Context.Object
  alias Durandal.Context
  use Durandal.Case, async: true

  alias Durandal.{ContextFixtures, AccountFixtures}

  defp valid_attrs do
    %{
      # VALID ATTRS
    }
  end

  defp update_attrs do
    %{
      # UPDATE ATTRS
    }
  end

  defp invalid_attrs do
    %{
      # INVALID ATTRS
    }
  end

  describe "object" do
    alias Durandal.Context.Object

    test "object_query/0 returns a query" do
      q = Context.object_query([])
      assert %Ecto.Query{} = q
    end

    test "list_object/0 returns object" do
      # No object yet
      assert Context.list_objects([]) == []

      # Add a object
      ContextFixtures.object_fixture()
      assert Context.list_objects([]) != []
    end

    test "get_object!/1 and get_object/1 returns the object with given id" do
      object = ContextFixtures.object_fixture()
      assert Context.get_object!(object.id) == object
      assert Context.get_object(object.id) == object
    end

    test "create_object/1 with valid data creates a object" do
      assert {:ok, %Object{} = object} =
               Context.create_object(valid_attrs())

      assert object.FIRST_STRING_FIELD == "some FIRST_STRING_FIELD"
    end

    test "create_object/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_object(invalid_attrs())
    end

    test "create_object/4 with valid data creates a object" do
      user_id = AccountFixtures.user_fixture().id

      assert {:ok, %Object{} = object} =
               Context.create_object(user_id, "ip", "some FIRST_STRING_FIELD", %{})

      assert object.FIRST_STRING_FIELD == "some FIRST_STRING_FIELD"
    end

    test "create_object/4 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_object(nil, nil, nil, nil)
    end

    test "create_anonymous_object/3 with valid data creates a object" do
      assert {:ok, %Object{} = object} =
               Context.create_anonymous_object("ip", "some FIRST_STRING_FIELD", %{})

      assert object.FIRST_STRING_FIELD == "some FIRST_STRING_FIELD"
    end

    test "create_anonymous_object/3 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_anonymous_object(nil, nil, nil)
    end

    test "update_object/2 with valid data updates the object" do
      object = ContextFixtures.object_fixture()

      assert {:ok, %Object{} = object} =
               Context.update_object(object, update_attrs())

      assert object.FIRST_STRING_FIELD == "some updated FIRST_STRING_FIELD"
    end

    test "update_object/2 with invalid data returns error changeset" do
      object = ContextFixtures.object_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Context.update_object(object, invalid_attrs())

      assert object == Context.get_object!(object.id)
    end

    test "delete_object/1 deletes the object" do
      object = ContextFixtures.object_fixture()
      assert {:ok, %Object{}} = Context.delete_object(object)

      assert_raise Ecto.NoResultsError, fn ->
        Context.get_object!(object.id)
      end

      assert Context.get_object(object.id) == nil
    end

    test "change_object/1 returns a object changeset" do
      object = ContextFixtures.object_fixture()
      assert %Ecto.Changeset{} = Context.change_object(object)
    end
  end
end
