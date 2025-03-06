defmodule Durandal.Game.ScenarioLib do
  @moduledoc """
  A set of functions for initialising game conditions

  Durandal.Game.ScenarioLib.load_from_file("basic")
  """
  alias Durandal.{Repo, Game}

  @spec uuid() :: Ecto.UUID.t()
  defp uuid(), do: Ecto.UUID.generate()

  @spec build_ids(map()) :: %{String.t() => Ecto.UUID.t()}
  defp build_ids(data) do
    data
    |> do_build_ids
    |> List.flatten()
    |> Map.new()
  end

  @spec do_build_ids(map()) :: list()
  defp do_build_ids(data) when is_map(data) do
    data
    |> Enum.map(fn
      {"id", "$" <> id} ->
        {"$" <> id, Ecto.UUID.generate()}

      {_key, %{} = v} ->
        do_build_ids(v)

      {_key, v} when is_list(v) ->
        Enum.map(v, &do_build_ids/1)

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil(&1))
  end

  defp do_build_ids(_), do: []

  @spec get_path(String.t()) :: String.t()
  defp get_path(name) do
    scenario_folder = Application.get_env(:durandal, :scenario_path)
    file_name = "#{name}.json"
    Application.app_dir(:durandal, Path.join(scenario_folder, file_name))
  end

  @spec load_from_file(String.t(), list()) :: :ok
  def load_from_file(name, opts \\ []) do
    name
    |> get_path()
    |> File.read!()
    |> Jason.decode!()
    |> load_from_struct(opts)
  end

  @spec load_from_struct(map(), list()) :: {:ok, Durandal.Game.Universe.t()}
  def load_from_struct(data, opts \\ []) do
    Repo.transaction(fn ->
      {:ok, universe} =
        Game.create_universe(%{
          name: opts[:name] || Ecto.UUID.generate(),
          active?: opts[:active?]
        })

      ids =
        build_ids(data)
        |> Map.put("$universe", universe.id)

      build_teams(data["teams"], ids)
      build_ship_types(data["ship_types"], ids)
      build_system_object_types(data["system_object_types"], ids)
      build_station_module_types(data["station_module_types"], ids)

      build_systems(data["systems"], ids)

      universe
    end)
  end

  defp build_teams(data, ids) do
    rows =
      data
      |> Enum.map(fn team ->
        %{
          id: ids[team["id"]],
          universe_id: ids["$universe"],
          name: team["name"],
          member_count: 0,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Player.Team, rows)
  end

  defp build_ship_types(data, ids) do
    rows =
      data
      |> Enum.map(fn type ->
        %{
          id: ids[type["id"]],
          universe_id: ids["$universe"],
          name: type["name"],
          max_health: type["max_health"],
          acceleration: type["acceleration"],
          build_time: type["build_time"],
          damage: type["damage"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Types.ShipType, rows)
  end

  defp build_system_object_types(data, ids) do
    rows =
      data
      |> Enum.map(fn type ->
        %{
          id: ids[type["id"]],
          universe_id: ids["$universe"],
          name: type["name"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Types.SystemObjectType, rows)
  end

  defp build_station_module_types(data, ids) do
    rows =
      data
      |> Enum.map(fn type ->
        %{
          id: ids[type["id"]],
          universe_id: ids["$universe"],
          name: type["name"],
          max_health: type["max_health"],
          build_time: type["build_time"],
          damage: type["damage"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Types.StationModuleType, rows)
  end

  defp build_systems(data, ids) do
    rows =
      data
      |> Enum.map(fn system ->
        %{
          id: ids[system["id"]],
          universe_id: ids["$universe"],
          name: system["name"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.System, rows)

    data
    |> Enum.each(fn system ->
      system_id = ids[system["id"]]

      build_system_objects(system["objects"], system_id, ids)
      build_stations(system["stations"], system_id, ids)
      build_ships(system["ships"], system_id, ids)
    end)
  end

  defp build_system_objects(data, system_id, ids) do
    rows =
      data
      |> Enum.map(fn system_object ->
        %{
          id: ids[system_object["id"]],
          name: system_object["name"],
          type_id: ids[system_object["type"]],
          universe_id: ids["$universe"],
          system_id: system_id,
          position: system_object["position"],
          velocity: system_object["velocity"],
          orbiting_id: ids[system_object["orbiting"]],
          orbit_clockwise: system_object["orbit_clockwise"],
          orbit_period: system_object["orbit_period"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.SystemObject, rows)
  end

  defp build_ships(data, system_id, ids) do
    rows =
      data
      |> Enum.map(fn ship ->
        %{
          id: ids[ship["id"]] || uuid(),
          name: ship["name"],
          team_id: ids[ship["team"]],
          type_id: ids[ship["type"]],
          universe_id: ids["$universe"],
          system_id: system_id,
          position: ship["position"],
          velocity: ship["velocity"],
          orbiting_id: ids[ship["orbiting"]],
          orbit_clockwise: ship["orbit_clockwise"],
          orbit_period: ship["orbit_period"],
          build_progress: ship["build_progress"],
          health: ship["health"],
          docked_with_id: ids[ship["docked_with"]],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.Ship, rows)
  end

  defp build_stations(data, system_id, ids) do
    rows =
      data
      |> Enum.map(fn station ->
        %{
          id: ids[station["id"]],
          name: station["name"],
          team_id: ids[station["team"]],
          universe_id: ids["$universe"],
          system_id: system_id,
          position: station["position"],
          velocity: station["velocity"],
          orbiting_id: ids[station["orbiting"]],
          orbit_clockwise: station["orbit_clockwise"],
          orbit_period: station["orbit_period"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.Station, rows)

    data
    |> Enum.each(fn station ->
      station_id = ids[station["id"]]

      build_station_modules(station["modules"], station_id, ids)
    end)
  end

  defp build_station_modules(data, station_id, ids) do
    rows =
      data
      |> Enum.map(fn module ->
        %{
          id: ids[module["id"]] || uuid(),
          type_id: ids[module["type"]],
          universe_id: ids["$universe"],
          station_id: station_id,
          build_progress: module["build_progress"],
          health: module["health"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.StationModule, rows)
  end
end
