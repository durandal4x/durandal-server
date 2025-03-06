defmodule Durandal.TeamMemberQueriesTest do
  @moduledoc false
  use Durandal.DataCase, async: true

  alias Durandal.Player.TeamMemberQueries

  describe "queries" do
    @empty_query TeamMemberQueries.team_member_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        TeamMemberQueries.team_member_query(
          where: [
            not_a_key1: "",
            not_a_key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        TeamMemberQueries.team_member_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        TeamMemberQueries.team_member_query(
          where: [
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now(),
            updated_after: DateTime.utc_now(),
            updated_before: DateTime.utc_now(),
            has_roles: "Some string",
            not_has_roles: "Some string",
            enabled?: true,
            enabled?: false,
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
            "Enabled",
            "Disabled",
            "Newest first",
            "Oldest first"
          ],
          preload: [
            :team,
            :user
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
