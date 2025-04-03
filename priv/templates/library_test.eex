defmodule Durandal.$ObjectLibTest do
  @moduledoc false
  alias Durandal.$Context.$Object
  alias Durandal.$Context
  use Durandal.DataCase, async: true

  alias Durandal.$ContextFixtures

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

  describe "$object" do
    alias Durandal.$Context.$Object

    test "$object_query/0 returns a query" do
      q = $Context.$object_query([])
      assert %Ecto.Query{} = q
    end

    test "list_$object/0 returns $object" do
      # No $object yet
      assert $Context.list_$objects([]) == []

      # Add a $object
      $ContextFixtures.$object_fixture()
      assert $Context.list_$objects([]) != []
    end

    test "get_$object!/1 and get_$object/1 returns the $object with given id" do
      $object = $ContextFixtures.$object_fixture()
      assert $Context.get_$object!($object.id) == $object
      assert $Context.get_$object($object.id) == $object
    end

    test "create_$object/1 with valid data creates a $object" do
      assert {:ok, %$Object{} = $object} =
               $Context.create_$object(valid_attrs())

      # VALIDATE CREATE VALUES
    end

    test "create_$object/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = $Context.create_$object(invalid_attrs())
    end

    test "update_$object/2 with valid data updates the $object" do
      $object = $ContextFixtures.$object_fixture()

      assert {:ok, %$Object{} = $object} =
               $Context.update_$object($object, update_attrs())

      # VALIDATE UPDATE VALUES
    end

    test "update_$object/2 with invalid data returns error changeset" do
      $object = $ContextFixtures.$object_fixture()

      assert {:error, %Ecto.Changeset{}} =
               $Context.update_$object($object, invalid_attrs())

      assert $object == $Context.get_$object!($object.id)
    end

    test "delete_$object/1 deletes the $object" do
      $object = $ContextFixtures.$object_fixture()
      assert {:ok, %$Object{}} = $Context.delete_$object($object)

      assert_raise Ecto.NoResultsError, fn ->
        $Context.get_$object!($object.id)
      end

      assert $Context.get_$object($object.id) == nil
    end

    test "change_$object/1 returns a $object changeset" do
      $object = $ContextFixtures.$object_fixture()
      assert %Ecto.Changeset{} = $Context.change_$object($object)
    end
  end
end
