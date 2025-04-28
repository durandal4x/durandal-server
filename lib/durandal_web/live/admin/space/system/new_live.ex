defmodule DurandalWeb.Admin.Space.System.NewLive do
  @moduledoc false
  use DurandalWeb, :live_view

  @impl true
  def mount(%{"universe_id" => universe_id}, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:universe_id, universe_id)
    |> assign(:site_menu_active, "game")
    |> ok
  end

  def mount(%{"universe_id" => universe_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:universe_id, universe_id)
     |> assign(:site_menu_active, "game")
     |> assign(:users, [])}
  end
end
