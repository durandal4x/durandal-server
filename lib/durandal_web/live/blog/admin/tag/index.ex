defmodule DurandalWeb.Admin.Blog.TagLive.Index do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case allow?(socket.assigns[:current_user], "admin") do
      true ->
        {:noreply, apply_action(socket, socket.assigns.live_action, params)}

      false ->
        {:noreply,
         socket
         |> redirect(to: ~p"/blog")}
    end
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Blog admin page")
    |> assign(:tags, Blog.list_tags(order_by: ["Name (A-Z)"]))
    |> assign(:tag, nil)
    |> assign(:site_menu_active, "blog")
    |> assign(:view_colour, Durandal.Blog.colours())
  end

  @impl true
  def handle_info({DurandalWeb.Blog.TagFormComponent, {:saved, _tag}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Tag created successfully")
     |> redirect(to: ~p"/admin/blog/tags")}
  end

  def handle_info(
        {DurandalWeb.Blog.TagFormComponent, {:updated_changeset, %{changes: tag}}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:tag, tag)}
  end
end
