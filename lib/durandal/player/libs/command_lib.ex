defmodule Durandal.Player.CommandLib do
  @moduledoc """
  Library of command related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Player.{Command, CommandQueries}

  def command_types("ship"), do: [{"Move to position", "move_to_position"}, {"Move to object", "move_to_object"}, {"Orbit object", "orbit_object"}, {"Move to station", "move_to_station"}, {"Move to ship", "move_to_ship"}, {"Dock", "dock"}]
  def command_types("station"), do: [{"Move to position", "move_to_position"}, {"Move to object", "move_to_object"}, {"Orbit object", "orbit_object"}, {"Move to station", "move_to_station"}, {"Move to ship", "move_to_ship"}]

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
end
