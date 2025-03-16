defmodule DurandalWeb.Team.IndexLive do
  use DurandalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "team")
    |> ok
  end
end
