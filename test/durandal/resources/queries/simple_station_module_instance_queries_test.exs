defmodule Durandal.SimpleStationModuleInstanceQueriesTest do
  @moduledoc false
  use Durandal.DataCase, async: true

  alias Durandal.Resources.SimpleStationModuleInstanceQueries

  describe "queries" do
    @empty_query SimpleStationModuleInstanceQueries.simple_station_module_instance_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        SimpleStationModuleInstanceQueries.simple_station_module_instance_query(
          where: [
            not_a_key1: "",
            not_a_key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        SimpleStationModuleInstanceQueries.simple_station_module_instance_query(
          where: [not_a_key: 1]
        )
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        SimpleStationModuleInstanceQueries.simple_station_module_instance_query(
          where: [
            id: ["005f5e0b-ee46-4c07-9f81-2d565c2ade30", "c11a487b-16a2-4806-bd7a-dcf110d16b61"],
            id: "005f5e0b-ee46-4c07-9f81-2d565c2ade30",
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now(),
            updated_after: DateTime.utc_now(),
            updated_before: DateTime.utc_now(),
            type_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            type_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            type_id: :is_nil,
            type_id: :not_nil,
            quantity: [123, 456],
            quantity: 789,
            universe_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            universe_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            universe_id: :is_nil,
            universe_id: :not_nil,
            station_module_id: [
              "92a26447-572e-4e3e-893c-42008287a9aa",
              "5bed6cfe-0ffd-40bf-ad49-4e82ca65c9be"
            ],
            station_module_id: "fc7cd2d5-004a-4799-8cec-0d198016e292",
            station_module_id: :is_nil,
            station_module_id: :not_nil
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: [
            :type,
            :universe,
            :station_module
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
