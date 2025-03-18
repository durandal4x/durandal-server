defmodule DurandalWeb.Admin.Blog.PostLive.Index do
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
        socket
        |> apply_action(socket.assigns.live_action, params)
        |> noreply

      false ->
        socket
        |> redirect(to: ~p"/blog")
        |> noreply
    end
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Blog admin page")
    |> assign(:post, %{})
    |> assign(:site_menu_active, "blog")
    |> assign(:view_colour, Blog.colours())
  end

  @impl true
  def handle_info({DurandalWeb.Blog.PostFormComponent, {:saved, _post}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Post created successfully")
     |> redirect(to: ~p"/blog")}
  end

  def handle_info(
        {DurandalWeb.Blog.PostFormComponent, {:updated_changeset, %{changes: post}}},
        socket
      ) do
    socket
    |> assign(:post, post)
    |> noreply
  end
end
