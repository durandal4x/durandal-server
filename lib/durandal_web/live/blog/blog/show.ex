defmodule DurandalWeb.Blog.BlogLive.Show do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Blog}
  import DurandalWeb.BlogComponents
  alias Phoenix.PubSub

  @impl true
  def mount(%{"post_id" => post_id_str}, _session, socket) do
    socket =
      if is_connected?(socket) do
        :ok = PubSub.subscribe(Durandal.PubSub, "blog_posts")
        post = Blog.get_post!(post_id_str, preload: [:poster, :tags])
        Blog.increment_post_view_count(post.id)

        socket
        |> assign(:post, post)
      else
        socket
        |> assign(:post, nil)
      end

    {:ok,
     socket
     |> assign(:site_menu_active, "blog")}
  end

  @impl true
  def handle_info(%{channel: "blog_posts", event: :post_created}, socket) do
    {:noreply, socket}
  end

  def handle_info(
        %{channel: "blog_posts", event: :post_updated, post: new_post},
        %{assigns: %{post: post}} = socket
      ) do
    socket =
      if post.id == new_post.id do
        db_post = Blog.get_post!(post.id, preload: [:tags, :poster])
        socket |> assign(:post, db_post)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_info(
        %{channel: "blog_posts", event: :post_deleted, post_id: post_id},
        %{assigns: %{post: post}} = socket
      ) do
    if post_id == post.id do
      {:noreply,
       socket
       |> redirect(to: ~p"/blog")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{channel: "blog_posts"}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-post", _, %{assigns: %{post: post} = assigns} = socket) do
    if assigns.current_user.id == post.poster_id || allow?(assigns.current_user, "Moderator") do
      Blog.delete_post(post)

      {:noreply,
       socket
       |> redirect(to: ~p"/blog")}
    else
      {:noreply, socket}
    end
  end
end
