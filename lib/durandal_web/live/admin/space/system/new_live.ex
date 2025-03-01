defmodule DurandalWeb.Admin.Space.System.NewLive do
  @moduledoc false
  use DurandalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> assign(:users, [])}
  end
end
