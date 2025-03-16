defmodule Durandal.Game.UniverseLib do
  @moduledoc """
  Library of universe related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Game.{Universe, UniverseQueries}

  @spec global_topic() :: String.t()
  def global_topic(), do: "Durandal.Global.Universe"

  @spec topic(Durandal.universe_id()) :: String.t()
  def topic(universe_id), do: "Durandal.Game.Universe:#{universe_id}"

  @doc """
  Returns the list of universes.

  ## Examples

      iex> list_universes()
      [%Universe{}, ...]

  """
  @spec list_universes(Durandal.query_args()) :: [Universe.t()]
  def list_universes(query_args) do
    query_args
    |> UniverseQueries.universe_query()
    |> Repo.all()
  end

  @doc """
  Gets a single universe.

  Raises `Ecto.NoResultsError` if the Universe does not exist.

  ## Examples

      iex> get_universe!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Universe{}

      iex> get_universe!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_universe!(Universe.id(), Durandal.query_args()) :: Universe.t()
  def get_universe!(universe_id, query_args \\ []) do
    (query_args ++ [id: universe_id, limit: 1])
    |> UniverseQueries.universe_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single universe.

  Returns nil if the Universe does not exist.

  ## Examples

      iex> get_universe("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Universe{}

      iex> get_universe("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_universe(Universe.id(), Durandal.query_args()) :: Universe.t() | nil
  def get_universe(universe_id, query_args \\ []) do
    (query_args ++ [id: universe_id, limit: 1])
    |> UniverseQueries.universe_query()
    |> Repo.one()
  end

  @doc """
  Gets a single universe by its id. If no universe is found, returns `nil`.

  Makes use of a Cache

  ## Examples

      iex> get_universe_by_id("09f4e0d9-13d1-4a32-8121-d52423dd8e7c")
      %User{}

      iex> get_universe_by_id("310dcab9-e7c2-4fc0-acd6-98035376a7be")
      nil
  """
  @spec get_universe_by_id(Durandal.universe_id()) :: Universe.t() | nil
  def get_universe_by_id(nil), do: nil
  def get_universe_by_id(universe_id) do
    case Cachex.get(:universe_by_universe_id_cache, universe_id) do
      {:ok, nil} ->
        universe = do_get_universe_by_id(universe_id)
        Cachex.put(:universe_by_universe_id_cache, universe_id, universe)
        universe

      {:ok, value} ->
        value
    end
  end

  @spec do_get_universe_by_id(Durandal.universe_id()) :: Universe.t() | nil
  defp do_get_universe_by_id(universe_id) do
    UniverseQueries.universe_query(id: universe_id, limit: 1)
    |> Repo.one()
  end

  @doc """
  Creates a universe.

  ## Examples

      iex> create_universe(%{field: value})
      {:ok, %Universe{}}

      iex> create_universe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_universe(map) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  def create_universe(attrs) do
    %Universe{}
    |> Universe.changeset(attrs)
    |> Repo.insert()
    |> Durandal.broadcast_on_ok(global_topic(), :universe, %{event: :created_universe})
  end

  @doc """
  Updates a universe.

  ## Examples

      iex> update_universe(universe, %{field: new_value})
      {:ok, %Universe{}}

      iex> update_universe(universe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_universe(Universe.t(), map) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  def update_universe(%Universe{} = universe, attrs) do
    universe
    |> Universe.changeset(attrs)
    |> Repo.update()
    |> Durandal.broadcast_on_ok(global_topic(), :universe, %{event: :updated_universe})
    |> Durandal.broadcast_on_ok(&topic/1, :universe, %{event: :updated_universe})
    |> Durandal.invalidate_cache_on_ok(:universe_by_universe_id_cache)
  end

  @doc """
  Deletes a universe.

  ## Examples

      iex> delete_universe(universe)
      {:ok, %Universe{}}

      iex> delete_universe(universe)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_universe(Universe.t()) :: {:ok, Universe.t()} | {:error, Ecto.Changeset.t()}
  def delete_universe(%Universe{} = universe) do
    Repo.delete(universe)
    |> Durandal.broadcast_on_ok(global_topic(), :universe, %{event: :deleted_universe})
    |> Durandal.broadcast_on_ok(&topic/1, :universe, %{event: :deleted_universe})
    |> Durandal.invalidate_cache_on_ok(:universe_by_universe_id_cache)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking universe changes.

  ## Examples

      iex> change_universe(universe)
      %Ecto.Changeset{data: %Universe{}}

  """
  @spec change_universe(Universe.t(), map) :: Ecto.Changeset.t()
  def change_universe(%Universe{} = universe, attrs \\ %{}) do
    Universe.changeset(universe, attrs)
  end

  # Server related functions
  @doc """
  Spins up a set of supervisors and servers related to running a universe universe, specifically:
  - `Durandal.Game.UniverseSupervisor`
  - `Durandal.Game.UniverseServer`
  - `Durandal.Game.UniverseRegistry`
  """
  # Durandal.Game.UniverseLib.start_universe_supervisor("db45755d-23f8-4a51-80bd-2bb9889785fe")
  @spec start_universe_supervisor(Durandal.universe_id()) :: {:ok, pid} | {:error, String.t()}
  def start_universe_supervisor(universe_id) do
    DynamicSupervisor.start_child(Durandal.GameSupervisor, {
      Durandal.Game.UniverseSupervisor,
      %{
        universe_id: universe_id
      }
    })
  end

  @spec stop_universe_supervisor(Durandal.universe_id()) :: :ok | {:error, String.t()}
  def stop_universe_supervisor(universe_id) do
    pid = get_game_supervisor_pid(universe_id)

    if pid do
      case Supervisor.stop(pid) do
        :ok -> :ok
        {:error, _reason} -> {:error, "Failed to stop supervisor"}
      end
    else
      :ok
    end
  end

  def supervisor_name(universe_id) do
    "universe_#{universe_id}_supervisor"
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  def dynamic_supervisor_name(universe_id) do
    "universe_#{universe_id}_dynamic_supervisor"
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  def task_supervisor_name(universe_id) do
    "universe_#{universe_id}_task_supervisor"
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  def registry_name(universe_id) do
    "universe_#{universe_id}_registry"
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  def server_name(universe_id) do
    "universe_#{universe_id}_server"
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  @spec get_game_supervisor_pid(Durandal.universe_id()) :: pid | nil
  def get_game_supervisor_pid(universe_id) do
    case Horde.Registry.lookup(Durandal.GameRegistry, universe_id) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  @spec get_universe_server_pid(Durandal.universe_id()) :: pid | nil
  def get_universe_server_pid(universe_id) do
    case Horde.Registry.lookup(Durandal.UniverseServerRegistry, universe_id) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  @doc false
  @spec cast_universe_server(Universe.id(), any) :: any | nil
  def cast_universe_server(universe_id, msg) do
    case get_universe_server_pid(universe_id) do
      nil ->
        nil

      pid ->
        GenServer.cast(pid, msg)
        :ok
    end
  end

  @doc false
  @spec call_universe_server(Universe.id(), any) :: any | nil
  def call_universe_server(universe_id, message) when is_binary(universe_id) do
    case get_universe_server_pid(universe_id) do
      nil ->
        nil

      pid ->
        try do
          GenServer.call(pid, message)

          # If the process has somehow died, we just return nil
        catch
          :exit, _ ->
            nil
        end
    end
  end

  # @doc false
  # @spec stop_universe_server(Universe.id()) :: :ok | nil
  # def stop_universe_server(universe_id) do
  #   case get_universe_pid(universe_id) do
  #     nil ->
  #       nil

  #     p ->
  #       Durandal.broadcast(universe_topic(universe_id), %{
  #         event: :universe_closed,
  #         universe_id: universe_id
  #       })

  #       Durandal.broadcast(global_universe_topic(), %{
  #         event: :universe_closed,
  #         universe_id: universe_id
  #       })

  #       DynamicSupervisor.terminate_child(Durandal.UniverseSupervisor, p)
  #       :ok
  #   end
  # end
end
