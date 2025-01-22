defmodule DurandalWeb.Admin.Game.HomeLive do
  use DurandalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")

    {:ok, socket}
  end
end
