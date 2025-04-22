defmodule Durandal.Game.ScenarioLib do
  @moduledoc """
  A set of functions for initialising game conditions

  Durandal.Game.ScenarioLib.load_from_file("basic", team_data: team_data, user_data: user_data)

  team_data is built based on the teams listed in the universe but is broadly expected to look like:
    team_data = %{
      "$team1" => %{"name" => "Team 1"},
      "$team2" => %{"name" => "Team 2"}
    }

  The user data is created in a similar manner

    user_data = %{
      "@leader1" => %{"name" => "alice", "roles" => ""},
      "@leader2" => %{"name" => "bob", "roles" => ""}
    }

  """
  alias Durandal.{Repo, Game, Account}

  @spec uuid() :: Ecto.UUID.t()
  defp uuid(), do: Ecto.UUID.generate()

  @spec get_user_data_from_file(String.t()) :: map()
  def get_user_data_from_file(name) do
    name
    |> get_path()
    |> File.read!()
    |> Jason.decode!()
    |> get_user_data_from_struct()
  end

  @doc """
  Given a scenario data object, get a list of the users offered as part of it.

  Example output:

    {[
      %{
        "id" => "$team1",
        "members" => [
          %{"default-name" => "Raghna", "id" => "@leader1", "roles" => []}
        ],
        "name" => "Team 1"
      },
      %{
        "id" => "$team2",
        "members" => [
          %{
            "default-name" => "Teifion",
            "id" => "@leader2",
            "roles" => ["r1", "r2"]
          }
        ],
        "name" => "Team 2"
      }
    ],
    [
      %{
        "default-name" => "Raghna",
        "id" => "@leader1",
        "label" => "leader1",
        "roles" => []
      },
      %{
        "default-name" => "Teifion",
        "id" => "@leader2",
        "label" => "leader2",
        "roles" => ["r1", "r2"]
      }
    ]}
  """
  @spec get_user_data_from_struct(map()) :: {map(), map()}
  def get_user_data_from_struct(data) do
    teams_data =
      data
      |> Map.get("teams", %{})

    users_data =
      teams_data
      |> Enum.map(fn
        %{"members" => members} ->
          members
          |> Enum.map(fn m ->
            Map.merge(m, %{
              "label" => String.replace(m["id"], "@", "")
            })
          end)

        _ ->
          []
      end)
      |> List.flatten()

    {teams_data, users_data}
  end

  @spec build_users(map()) :: any
  defp build_users(user_data) do
    user_data
    |> Map.new(fn {shortcut, %{"name" => user_name}} ->
      user = Account.get_user_by_name(user_name)
      {shortcut, user.id}
    end)
  end

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
        |> Map.merge(build_users(opts[:user_data] || %{}))

      build_teams(data["teams"], ids, opts[:team_data])
      build_ship_types(data["ship_types"], ids)
      build_system_object_types(data["system_object_types"], ids)
      build_station_module_types(data["station_module_types"], ids)
      build_team_members(data["teams"], ids, opts[:user_data] || %{})
      build_systems(data["systems"], ids)

      universe
    end)
  end

  defp build_teams(data, ids, team_data) do
    rows =
      data
      |> Enum.map(fn team ->
        team_data_row = team_data[team["id"]]

        %{
          id: Map.fetch!(ids, team["id"]),
          universe_id: Map.fetch!(ids, "$universe"),
          name: team_data_row["name"] || team["name"],
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
          id: Map.fetch!(ids, type["id"]),
          universe_id: Map.fetch!(ids, "$universe"),
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
          id: Map.fetch!(ids, type["id"]),
          universe_id: Map.fetch!(ids, "$universe"),
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
          id: Map.fetch!(ids, type["id"]),
          universe_id: Map.fetch!(ids, "$universe"),
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
          id: Map.fetch!(ids, system["id"]),
          universe_id: Map.fetch!(ids, "$universe"),
          name: system["name"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.System, rows)

    data
    |> Enum.each(fn system ->
      system_id = Map.fetch!(ids, system["id"])

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
          id: Map.fetch!(ids, system_object["id"]),
          name: system_object["name"],
          type_id: Map.fetch!(ids, system_object["type"]),
          universe_id: Map.fetch!(ids, "$universe"),
          system_id: system_id,
          position: system_object["position"],
          velocity: system_object["velocity"],
          orbiting_id: Map.get(ids, system_object["orbiting"]),
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
          id: Map.fetch!(ids, ship["id"]),
          name: ship["name"],
          team_id: Map.fetch!(ids, ship["team"]),
          type_id: Map.fetch!(ids, ship["type"]),
          universe_id: Map.fetch!(ids, "$universe"),
          system_id: system_id,
          position: ship["position"],
          velocity: ship["velocity"],
          orbiting_id: Map.get(ids, ship["orbiting"]),
          orbit_clockwise: ship["orbit_clockwise"],
          orbit_period: ship["orbit_period"],
          build_progress: ship["build_progress"],
          health: ship["health"],
          docked_with_id: Map.get(ids, ship["docked_with"]),
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.Ship, rows)
    build_ship_commands(data, ids)
  end

  defp build_ship_commands(data, ids) do
    rows =
      data
      |> Enum.filter(fn ship -> Map.get(ship, "commands") != nil end)
      |> Enum.map(fn ship ->
        ship["commands"]
        |> Enum.with_index()
        |> Enum.map(fn {command, idx} ->
          %{
            id: Ecto.UUID.generate(),
            command_type: command["type"],
            subject_type: "ship",
            subject_id: Map.fetch!(ids, ship["id"]),
            ordering: idx,
            contents: apply_ids(command["contents"], ids),
            team_id: Map.fetch!(ids, ship["team"]),
            user_id: Map.fetch!(ids, command["user"]),
            universe_id: Map.fetch!(ids, "$universe"),
            progress: 0,
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        end)
      end)
      |> List.flatten()

    Repo.insert_all(Durandal.Player.Command, rows)
  end

  defp build_stations(data, system_id, ids) do
    rows =
      data
      |> Enum.map(fn station ->
        %{
          id: Map.fetch!(ids, station["id"]),
          name: station["name"],
          team_id: Map.fetch!(ids, station["team"]),
          universe_id: Map.fetch!(ids, "$universe"),
          system_id: system_id,
          position: station["position"],
          velocity: station["velocity"],
          orbiting_id: Map.get(ids, station["orbiting"]),
          orbit_clockwise: station["orbit_clockwise"],
          orbit_period: station["orbit_period"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.Station, rows)
    build_station_commands(data, ids)

    data
    |> Enum.each(fn station ->
      station_id = Map.fetch!(ids, station["id"])

      build_station_modules(station["modules"], station_id, ids)
    end)
  end

  defp build_station_commands(data, ids) do
    rows =
      data
      |> Enum.filter(fn station -> Map.get(station, "commands") != nil end)
      |> Enum.map(fn station ->
        station["commands"]
        |> Enum.with_index()
        |> Enum.map(fn {command, idx} ->
          %{
            id: Ecto.UUID.generate(),
            command_type: command["type"],
            subject_type: "station",
            subject_id: Map.fetch!(ids, station["id"]),
            ordering: idx,
            contents: apply_ids(command["contents"], ids),
            team_id: Map.fetch!(ids, station["team"]),
            user_id: Map.fetch!(ids, command["user"]),
            universe_id: Map.fetch!(ids, "$universe"),
            progress: 0,
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        end)
      end)
      |> List.flatten()

    Repo.insert_all(Durandal.Player.Command, rows)
  end

  defp build_station_modules(data, station_id, ids) do
    rows =
      data
      |> Enum.map(fn module ->
        %{
          id: Map.get(ids, module["id"], uuid()),
          type_id: Map.fetch!(ids, module["type"]),
          universe_id: Map.fetch!(ids, "$universe"),
          station_id: station_id,
          build_progress: module["build_progress"],
          health: module["health"],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Space.StationModule, rows)
  end

  defp build_team_members(data, ids, user_data) do
    # Build a lookup of the member_key => team_id
    team_lookup =
      data
      |> Enum.map(fn team_row ->
        team_row
        |> Map.get("members", [])
        |> Enum.map(fn member ->
          {member["id"], Map.fetch!(ids, team_row["id"])}
        end)
      end)
      |> List.flatten()
      |> Map.new()

    # Now the actual team members
    rows =
      user_data
      |> Enum.map(fn {key, user_row} ->
        roles =
          if is_list(user_row["roles"]) do
            user_row["roles"]
          else
            user_row["roles"] |> String.split(",") |> Enum.map(&String.trim/1)
          end

        %{
          roles: roles,
          enabled?: true,
          team_id: team_lookup[key],
          user_id: Map.fetch!(ids, key),
          universe_id: Map.fetch!(ids, "$universe"),
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(Durandal.Player.TeamMember, rows)
  end

  defp apply_ids(the_map, ids) when is_map(the_map) do
    the_map
    |> Map.new(fn {k, v} -> {apply_ids(k, ids), apply_ids(v, ids)} end)
  end

  defp apply_ids(the_list, ids) when is_list(the_list) do
    the_list
    |> Enum.map(fn v -> apply_ids(v, ids) end)
  end

  defp apply_ids(v, ids), do: Map.get(ids, v, v)
end
