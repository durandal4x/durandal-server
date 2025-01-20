defmodule Durandal.ObjectQueriesTest do
  @moduledoc false
  use Durandal.Case, async: true

  alias Durandal.Context.ObjectQueries

  describe "queries" do
    @empty_query ObjectQueries.object_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        ObjectQueries.object_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        ObjectQueries.object_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        ObjectQueries.object_query(
          where: [
            id: [1, 2],
            id: 1,
            inserted_after: Timex.now(),
            inserted_before: Timex.now(),
            updated_after: Timex.now(),
            updated_before: Timex.now()
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: []
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
