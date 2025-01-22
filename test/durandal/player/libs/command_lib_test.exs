defmodule Durandal.CommandLibTest do
  @moduledoc false
  alias Durandal.Player.Command
  alias Durandal.Player
  use Durandal.DataCase, async: true

  alias Durandal.{PlayerFixtures, AccountFixtures}

  defp valid_attrs do
    %{
      command_type: "some command_type",
      subject_type: "some subject_type",
      subject_id: "f93c0484-8e12-49ef-bc8c-1055090e94e7",
      ordering: 123,
      contents: %{"key1" => 123, "key2" => "value"},
      team_id: PlayerFixtures.team_fixture().id,
      user_id: AccountFixtures.user_fixture().id
    }
  end

  defp update_attrs do
    %{
      command_type: "some updated command_type",
      subject_type: "some updated subject_type",
      subject_id: "2c77b935-4b83-491a-92ab-a35045803609",
      ordering: 456,
      contents: %{"key1" => 123, "key3" => "value"},
      team_id: PlayerFixtures.team_fixture().id,
      user_id: AccountFixtures.user_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      command_type: nil,
      subject_type: nil,
      subject_id: nil,
      ordering: nil,
      contents: nil,
      team_id: nil,
      user_id: nil
    }
  end

  describe "command" do
    alias Durandal.Player.Command

    test "command_query/0 returns a query" do
      q = Player.command_query([])
      assert %Ecto.Query{} = q
    end

    test "list_command/0 returns command" do
      # No command yet
      assert Player.list_commands([]) == []

      # Add a command
      PlayerFixtures.command_fixture()
      assert Player.list_commands([]) != []
    end

    test "get_command!/1 and get_command/1 returns the command with given id" do
      command = PlayerFixtures.command_fixture()
      assert Player.get_command!(command.id) == command
      assert Player.get_command(command.id) == command
    end

    test "create_command/1 with valid data creates a command" do
      assert {:ok, %Command{} = command} =
               Player.create_command(valid_attrs())

      assert command.command_type == "some command_type"
      assert command.subject_type == "some subject_type"
      assert command.ordering == 123
      assert command.contents == %{"key1" => 123, "key2" => "value"}
    end

    test "create_command/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Player.create_command(invalid_attrs())
    end

    test "update_command/2 with valid data updates the command" do
      command = PlayerFixtures.command_fixture()

      assert {:ok, %Command{} = command} =
               Player.update_command(command, update_attrs())

      assert command.command_type == "some updated command_type"
      assert command.subject_type == "some updated subject_type"
      assert command.ordering == 456
      assert command.contents == %{"key1" => 123, "key3" => "value"}
    end

    test "update_command/2 with invalid data returns error changeset" do
      command = PlayerFixtures.command_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Player.update_command(command, invalid_attrs())

      assert command == Player.get_command!(command.id)
    end

    test "delete_command/1 deletes the command" do
      command = PlayerFixtures.command_fixture()
      assert {:ok, %Command{}} = Player.delete_command(command)

      assert_raise Ecto.NoResultsError, fn ->
        Player.get_command!(command.id)
      end

      assert Player.get_command(command.id) == nil
    end

    test "change_command/1 returns a command changeset" do
      command = PlayerFixtures.command_fixture()
      assert %Ecto.Changeset{} = Player.change_command(command)
    end
  end
end
