defmodule Durandal.$ObjectQueriesTest do
  @moduledoc false
  use Durandal.DataCase, async: true

  alias Durandal.$Context.$ObjectQueries

  describe "queries" do
    @empty_query $ObjectQueries.$object_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        $ObjectQueries.$object_query(
          where: [
            not_a_key1: "",
            not_a_key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        $ObjectQueries.$object_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        $ObjectQueries.$object_query(
          where: [
            id: ["$uuid1", "$uuid2"],
            id: "$uuid1",
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now(),
            updated_after: DateTime.utc_now(),
            updated_before: DateTime.utc_now(),
            # FIELD TEST
          ],
          order_by: [
            "Newest first",
            "Oldest first",
            # ORDER BY TEST
          ],
          preload: [
            # PRELOAD TESTS
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
