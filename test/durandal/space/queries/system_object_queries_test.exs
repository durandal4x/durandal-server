defmodule Durandal.SystemObjectQueriesTest do
  @moduledoc false
  use Durandal.DataCase, async: true

  alias Durandal.Space.SystemObjectQueries

  describe "queries" do
    @empty_query SystemObjectQueries.system_object_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        SystemObjectQueries.system_object_query(
          where: [
            not_a_key1: "",
            not_a_key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        SystemObjectQueries.system_object_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        SystemObjectQueries.system_object_query(
          where: [
            id: ["005f5e0b-ee46-4c07-9f81-2d565c2ade30", "c11a487b-16a2-4806-bd7a-dcf110d16b61"],
            id: "005f5e0b-ee46-4c07-9f81-2d565c2ade30",
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now(),
            updated_after: DateTime.utc_now(),
            updated_before: DateTime.utc_now(),
            name: ["Some string", "Another string"],
            name: "Some string",
            type_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            type_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            system_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            system_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            has_position: 123,
            not_has_position: 456,
            has_velocity: 123,
            not_has_velocity: 456,
            orbiting_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            orbiting_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            universe_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            universe_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            orbit_clockwise: [true, false],
            orbit_clockwise: true,
            orbit_period: [123, 456],
            orbit_period: 789
          ],
          order_by: [
            "Newest first",
            "Oldest first",
            "Name (A-Z)",
            "Name (Z-A)"
          ],
          preload: [
            :type,
            :system,
            :orbiting,
            :universe
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
