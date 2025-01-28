defmodule Durandal.Player.TeamMemberLib do
  @moduledoc """
  Library of team_member related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Player.{TeamMember, TeamMemberQueries}

  @doc """
  Returns the list of team_members.

  ## Examples

      iex> list_team_members()
      [%TeamMember{}, ...]

  """
  @spec list_team_members(Durandal.query_args()) :: [TeamMember.t()]
  def list_team_members(query_args) do
    query_args
    |> TeamMemberQueries.team_member_query()
    |> Repo.all()
  end

  @doc """
  Gets a single team_member.

  Raises `Ecto.NoResultsError` if the TeamMember does not exist.

  ## Examples

      iex> get_team_member!("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %TeamMember{}

      iex> get_team_member!("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      ** (Ecto.NoResultsError)

  """
  @spec get_team_member!(TeamMember.id(), Durandal.query_args()) :: TeamMember.t()
  def get_team_member!(team_member_id, query_args \\ []) do
    (query_args ++ [id: team_member_id])
    |> TeamMemberQueries.team_member_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single team_member.

  Returns nil if the TeamMember does not exist.

  ## Examples

      iex> get_team_member("005f5e0b-ee46-4c07-9f81-2d565c2ade30")
      %TeamMember{}

      iex> get_team_member("c11a487b-16a2-4806-bd7a-dcf110d16b61")
      nil

  """
  @spec get_team_member(TeamMember.id(), Durandal.query_args()) :: TeamMember.t() | nil
  def get_team_member(team_member_id, query_args \\ []) do
    (query_args ++ [id: team_member_id])
    |> TeamMemberQueries.team_member_query()
    |> Repo.one()
  end

  @doc """
  Creates a team_member.

  ## Examples

      iex> create_team_member(%{field: value})
      {:ok, %TeamMember{}}

      iex> create_team_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_team_member(map) :: {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def create_team_member(attrs) do
    %TeamMember{}
    |> TeamMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team_member.

  ## Examples

      iex> update_team_member(team_member, %{field: new_value})
      {:ok, %TeamMember{}}

      iex> update_team_member(team_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_team_member(TeamMember.t(), map) ::
          {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def update_team_member(%TeamMember{} = team_member, attrs) do
    team_member
    |> TeamMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team_member.

  ## Examples

      iex> delete_team_member(team_member)
      {:ok, %TeamMember{}}

      iex> delete_team_member(team_member)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_team_member(TeamMember.t()) :: {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def delete_team_member(%TeamMember{} = team_member) do
    Repo.delete(team_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_member changes.

  ## Examples

      iex> change_team_member(team_member)
      %Ecto.Changeset{data: %TeamMember{}}

  """
  @spec change_team_member(TeamMember.t(), map) :: Ecto.Changeset.t()
  def change_team_member(%TeamMember{} = team_member, attrs \\ %{}) do
    TeamMember.changeset(team_member, attrs)
  end
end
