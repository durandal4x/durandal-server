defmodule Durandal.CommandQueriesTest do
  @moduledoc false
  use Durandal.DataCase, async: true

  alias Durandal.Player.CommandQueries

  describe "queries" do
    @empty_query CommandQueries.command_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        CommandQueries.command_query(
          where: [
            not_a_key1: "",
            not_a_key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        CommandQueries.command_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        CommandQueries.command_query(
          where: [
            id: ["005f5e0b-ee46-4c07-9f81-2d565c2ade30", "c11a487b-16a2-4806-bd7a-dcf110d16b61"],
            id: "005f5e0b-ee46-4c07-9f81-2d565c2ade30",
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now(),
            updated_after: DateTime.utc_now(),
            updated_before: DateTime.utc_now(),
            command_type: ["Some string", "Another string"],
            command_type: "Some string",
            subject_type: ["Some string", "Another string"],
            subject_type: "Some string",
            subject: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            subject: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            ordering: [123, 456],
            ordering: 789,
            team_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            team_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            user_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            user_id: "fc7cd2d5-004a-4799-8cec-0d198016e292"
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: [
            :player_teams,
            :account_users
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end