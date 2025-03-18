defmodule DurandalWeb.Admin.Blog.TagLive.Show do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    case allow?(socket.assigns[:current_user], "admin") do
      true ->
        {:noreply,
         socket
         |> assign(:tag, Blog.get_tag!(id))
         |> assign(:site_menu_active, "blog")
         |> assign(:view_colour, Durandal.Blog.colours())}

      false ->
        {:noreply,
         socket
         |> redirect(to: ~p"/blog")}
    end
  end
end
