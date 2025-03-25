defmodule Durandal.SimCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Durandal.SimCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  alias Durandal.Game.{UniverseLib, ScenarioLib}

  using do
    quote do
      alias Durandal.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Durandal.SimCase
      import Durandal.{AccountFixtures, PlayerFixtures, TypesFixtures, SpaceFixtures}
    end
  end

  setup tags do
    Durandal.SimCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Durandal.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def start_universe(%{} = scenario_struct, opts) do
    {:ok, universe} = ScenarioLib.load_from_struct(scenario_struct, opts)
    {:ok, _pid} = UniverseLib.start_universe_supervisor(universe.id)

    universe
  end

  def start_universe(scenario_name, opts) do
    {:ok, universe} = ScenarioLib.load_from_file(scenario_name, opts)
    {:ok, _pid} = UniverseLib.start_universe_supervisor(universe.id)

    universe
  end

  def tick_universe(universe_id, tick_count \\ 1) do
    UniverseLib.cast_universe_server(universe_id, :force_perform_tick)
    await_tick_completion(universe_id)

    if tick_count > 1, do: tick_universe(universe_id, tick_count - 1)
  end

  def tear_down(_universe_id) do
    # We used to tear these down but it caused the supervisor to restart with
    # ** (exit) :reached_max_restart_intensity
    # which caused the main application supervisor to restart and thus the repo was no longer present
    # We found this by setting `handle_sasl_reports: true` in the logger config
    # In theory setting max_restarts to a high number should have worked but it did not

    # UniverseLib.stop_universe_supervisor(universe_id)
    # :timer.sleep(500)
  end

  def await_tick_completion(universe_id, sleep_time \\ 10) do
    if UniverseLib.call_universe_server(universe_id, :tick_in_progress?) do
      :timer.sleep(sleep_time)
      await_tick_completion(universe_id, sleep_time)
    end
  end
end
