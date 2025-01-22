defmodule Durandal.UniverseQueriesTest do
  @moduledoc false
  use Durandal.Case, async: true

  alias Durandal.Game.UniverseQueries

  describe "queries" do
    @empty_query UniverseQueries.universe_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        UniverseQueries.universe_query(
          where: [
            not_a_key1: "",
            not_a_key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        UniverseQueries.universe_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        UniverseQueries.universe_query(
          where: [
            id: ["005f5e0b-ee46-4c07-9f81-2d565c2ade30", "c11a487b-16a2-4806-bd7a-dcf110d16b61"],
            id: "005f5e0b-ee46-4c07-9f81-2d565c2ade30",
            name: ["Some string", "Another string"],
            name: "Some string",
            active?: [true, false],
            active?: true,
            inserted_after: Timex.now(),
            inserted_before: Timex.now(),
            updated_after: Timex.now(),
            updated_before: Timex.now()
          ],
          order_by: [
            "name (A-Z)",
            "name (Z-A)",
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
