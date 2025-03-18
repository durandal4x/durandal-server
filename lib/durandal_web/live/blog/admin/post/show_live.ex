defmodule DurandalWeb.Admin.Blog.PostLive.Show do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    if allow?(socket.assigns[:current_user], "admin") do
      post = Blog.get_post!(id, preload: [:tags])

      if post.poster_id == socket.assigns.current_user.id or
           allow?(socket.assigns[:current_user], "admin") do
        post = Blog.get_post!(id, preload: [:tags])
        selected_tags = post.tags |> Enum.map(fn t -> t.id end)

        socket
        |> assign(:post, post)
        |> assign(:selected_tags, selected_tags)
        |> assign(:site_menu_active, "blog")
        |> assign(:view_colour, Durandal.Blog.colours())
        |> noreply
      else
        {:noreply, socket |> redirect(to: ~p"/admin/blog/posts")}
      end
    else
      {:noreply, socket |> redirect(to: ~p"/blog")}
    end
  end
end
