defmodule Durandal.Player.CommandLib do
  @moduledoc """
  Library of command related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Player.{Command, CommandQueries}

  # def command_types("ship"), do: [{"Move to position", "move_to_position"}, {"Move to object", "move_to_object"}, {"Orbit object", "orbit_object"}, {"Move to station", "move_to_station"}, {"Move to ship", "move_to_ship"}, {"Dock", "dock"}]

  def command_types(subject, _language) do
    command_lookup()
    |> Enum.filter(fn {key, _module} -> String.starts_with?(key, "#{subject}$") end)
    |> Map.new(fn {_key, module} ->
      # TODO: Put in translation stuff
      {module.name(), module.name()}
    end)
  end

  @doc """
  Returns the list of commands.

  ## Examples

      iex> list_commands()
      [%Command{}, ...]

  """
  @spec list_commands(Durandal.query_args()) :: [Command.t()]
  def list_commands(query_args) do
    query_args
    |> CommandQueries.command_query()
    |> Repo.all()
  end

  @doc """
  Gets a single command.

  Raises `Ecto.NoResultsError` if the Command does not exist.

  ## Examples

      iex> get_command!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Command{}

      iex> get_command!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_command!(Command.id(), Durandal.query_args()) :: Command.t()
  def get_command!(command_id, query_args \\ []) do
    (query_args ++ [id: command_id])
    |> CommandQueries.command_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single command.

  Returns nil if the Command does not exist.

  ## Examples

      iex> get_command("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %Command{}

      iex> get_command("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_command(Command.id(), Durandal.query_args()) :: Command.t() | nil
  def get_command(command_id, query_args \\ []) do
    (query_args ++ [id: command_id])
    |> CommandQueries.command_query()
    |> Repo.one()
  end

  @doc """
  Creates a command.

  ## Examples

      iex> create_command(%{field: value})
      {:ok, %Command{}}

      iex> create_command(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_command(map) :: {:ok, Command.t()} | {:error, Ecto.Changeset.t()}
  def create_command(attrs) do
    %Command{}
    |> Command.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a command.

  ## Examples

      iex> update_command(command, %{field: new_value})
      {:ok, %Command{}}

      iex> update_command(command, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_command(Command.t(), map) :: {:ok, Command.t()} | {:error, Ecto.Changeset.t()}
  def update_command(%Command{} = command, attrs) do
    command
    |> Command.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a command.

  ## Examples

      iex> delete_command(command)
      {:ok, %Command{}}

      iex> delete_command(command)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_command(Command.t()) :: {:ok, Command.t()} | {:error, Ecto.Changeset.t()}
  def delete_command(%Command{} = command) do
    Repo.delete(command)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking command changes.

  ## Examples

      iex> change_command(command)
      %Ecto.Changeset{data: %Command{}}

  """
  @spec change_command(Command.t(), map) :: Ecto.Changeset.t()
  def change_command(%Command{} = command, attrs \\ %{}) do
    Command.changeset(command, attrs)
  end

  @doc """
  A map of %{command name => command module) for all commands
  """
  @spec command_lookup() :: %{String.t() => module()}
  def command_lookup() do
    case Cachex.get(:durandal_command_modules, "_complete") do
      {:ok, nil} ->
        {:ok, lookup} = build_command_lookup()
        lookup

      {:ok, lookup} ->
        lookup
    end
  end

  @spec get_command_module(String.t()) :: {:ok, nil | module()}
  def get_command_module(combined_name) do
    Cachex.get(:durandal_command_modules, combined_name)
  end

  @spec get_command_module(String.t(), String.t()) :: {:ok, nil | module()}
  def get_command_module(type, name) do
    Cachex.get(:durandal_command_modules, "#{type}$#{name}")
  end

  @spec get_command_module!(String.t()) :: nil | module()
  def get_command_module!(combined_name) do
    Cachex.get!(:durandal_command_modules, combined_name)
  end

  @spec get_command_module!(String.t(), String.t()) :: nil | module()
  def get_command_module!(type, name) do
    Cachex.get!(:durandal_command_modules, "#{type}$#{name}")
  end

  def build_command_lookup() do
    {:ok, command_list} = :application.get_key(:durandal, :modules)

    # First, build the lookup from commands implementing this behaviour
    # and exporting a name/0 function
    lookup =
      command_list
      |> Enum.filter(fn m ->
        Code.ensure_loaded(m)

        system_macro? =
          case Code.loaded?(m) && m.__info__(:attributes)[:behaviour] do
            false -> false
            [] -> false
            nil -> false
            b -> Enum.member?(b, Durandal.Engine.CommandMacro)
          end

        system_macro? and function_exported?(m, :name, 0)
      end)
      |> Map.new(fn m ->
        {"#{m.category()}$#{m.name()}", m}
      end)

    old = Cachex.get!(:durandal_command_modules, "_all") || []

    # Store all keys, we'll use it later for removing old ones
    Cachex.put(:durandal_command_modules, "_all", lookup)

    # Now store our lookups
    lookup
    |> Enum.each(fn {key, func} ->
      Cachex.put(:durandal_command_modules, key, func)
    end)

    # And a copy of the complete lookup since we'll want to pull that back sometimes rather than doing several round trips
    Cachex.put(:durandal_command_modules, "_complete", lookup)

    # Delete out-dated keys
    old
    |> Enum.reject(fn old_key ->
      Map.has_key?(lookup, old_key)
    end)
    |> Enum.each(fn old_key ->
      Cachex.del(:durandal_command_modules, old_key)
    end)

    {:ok, lookup}
  end
end
