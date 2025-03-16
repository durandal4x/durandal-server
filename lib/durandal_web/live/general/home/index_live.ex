defmodule DurandalWeb.General.IndexLive do
  use DurandalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    if socket.assigns.current_user do
      {:ok,
       socket
       |> assign(:site_menu_active, "home")}
    else
      {:ok, redirect(socket, to: ~p"/guest")}
    end
  end

  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/guest")}
    end
  end
end
