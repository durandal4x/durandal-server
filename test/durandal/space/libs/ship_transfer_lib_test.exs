defmodule Durandal.ShipTransferLibTest do
  @moduledoc false
  alias Durandal.Space.ShipTransfer
  alias Durandal.Space
  use Durandal.DataCase, async: true

  alias Durandal.{SpaceFixtures, GameFixtures}

  defp valid_attrs do
    %{
      origin: [123, 456, 789],
      to_station_id: SpaceFixtures.station_fixture().id,
      to_system_object_id: nil,
      universe_id: GameFixtures.universe_fixture().id,
      ship_id: SpaceFixtures.ship_fixture().id,
      distance: 123,
      progress: 123,
      status: "some status",
      started_tick: 123,
      completed_tick: 123
    }
  end

  defp update_attrs do
    %{
      origin: [1230, 4560, 7890],
      to_station_id: nil,
      to_system_object_id: SpaceFixtures.system_object_fixture().id,
      universe_id: GameFixtures.universe_fixture().id,
      ship_id: SpaceFixtures.ship_fixture().id,
      distance: 456,
      progress: 456,
      status: "some updated status",
      started_tick: 456,
      completed_tick: 456
    }
  end

  defp invalid_attrs do
    %{
      origin: nil,
      to_station_id: nil,
      to_system_object_id: nil,
      universe_id: nil,
      ship_id: nil,
      distance: nil,
      progress: nil,
      status: nil,
      started_tick: nil,
      completed_tick: nil
    }
  end

  describe "ship_transfer" do
    alias Durandal.Space.ShipTransfer

    test "ship_transfer_query/0 returns a query" do
      q = Space.ship_transfer_query([])
      assert %Ecto.Query{} = q
    end

    test "list_ship_transfer/0 returns ship_transfer" do
      # No ship_transfer yet
      assert Space.list_ship_transfers([]) == []

      # Add a ship_transfer
      SpaceFixtures.ship_transfer_fixture()
      assert Space.list_ship_transfers([]) != []
    end

    test "get_ship_transfer!/1 and get_ship_transfer/1 returns the ship_transfer with given id" do
      ship_transfer = SpaceFixtures.ship_transfer_fixture()
      assert Space.get_ship_transfer!(ship_transfer.id) == ship_transfer
      assert Space.get_ship_transfer(ship_transfer.id) == ship_transfer
    end

    test "create_ship_transfer/1 with valid data creates a ship_transfer" do
      assert {:ok, %ShipTransfer{} = ship_transfer} =
               Space.create_ship_transfer(valid_attrs())

      assert ship_transfer.distance == 123
      assert ship_transfer.progress == 123
      assert ship_transfer.status == "some status"
      assert ship_transfer.started_tick == 123
      assert ship_transfer.completed_tick == 123
    end

    test "create_ship_transfer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Space.create_ship_transfer(invalid_attrs())
    end

    test "update_ship_transfer/2 with valid data updates the ship_transfer" do
      ship_transfer = SpaceFixtures.ship_transfer_fixture()

      assert {:ok, %ShipTransfer{} = ship_transfer} =
               Space.update_ship_transfer(ship_transfer, update_attrs())

      assert ship_transfer.distance == 456
      assert ship_transfer.progress == 456
      assert ship_transfer.status == "some updated status"
      assert ship_transfer.started_tick == 456
      assert ship_transfer.completed_tick == 456
    end

    test "update_ship_transfer/2 with invalid data returns error changeset" do
      ship_transfer = SpaceFixtures.ship_transfer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Space.update_ship_transfer(ship_transfer, invalid_attrs())

      assert ship_transfer == Space.get_ship_transfer!(ship_transfer.id)
    end

    test "delete_ship_transfer/1 deletes the ship_transfer" do
      ship_transfer = SpaceFixtures.ship_transfer_fixture()
      assert {:ok, %ShipTransfer{}} = Space.delete_ship_transfer(ship_transfer)

      assert_raise Ecto.NoResultsError, fn ->
        Space.get_ship_transfer!(ship_transfer.id)
      end

      assert Space.get_ship_transfer(ship_transfer.id) == nil
    end

    test "change_ship_transfer/1 returns a ship_transfer changeset" do
      ship_transfer = SpaceFixtures.ship_transfer_fixture()
      assert %Ecto.Changeset{} = Space.change_ship_transfer(ship_transfer)
    end
  end
end
