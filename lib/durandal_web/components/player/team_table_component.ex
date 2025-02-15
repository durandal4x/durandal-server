defmodule DurandalWeb.Player.TeamTableComponent do
  @moduledoc """
  Not used, leaving here temporarily incase I want to use it as a starting point


  <.live_component
    module={DurandalWeb.Player.TeamTableComponent}
    universe_id={@universe.id}
    query_opts={@team_query_opts}
    id="teams-table"
  />
  """

  use DurandalWeb, :live_component
  alias Durandal.{Game, Player}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="#{@id || teams}" rows={@streams.teams} table_class="table-sm table-hover">
        <:col :let={{_id, team}} label="Name">{team.name}</:col>

        <:action :let={{_id, team}}>
          <.link navigate={~p"/admin/teams/#{team}"} class="btn btn-secondary btn-sm">
            Show
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:query_opts, nil)
    |> stream(:teams, [])
    |> ok
  end

  @impl true
  def update(%{query_opts: query_opts, universe_id: universe_id} = assigns, socket) do
    if universe_id do
      :ok = Durandal.subscribe(Durandal.Game.universe_topic(universe_id))
    end

    socket
    |> rerun_query()
    |> ok
  end

  def update(assigns, socket) do
    socket
    |> ok
  end

  defp rerun_query(%{assigns: %{query_opts: query_opts}} = socket) do
    teams =
      Player.list_teams(query_opts)

    socket
    |> stream(:teams, teams, reset: true)
  end
end
