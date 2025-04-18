defmodule DurandalWeb.Blog.BlogLive.Show do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Blog}
  import DurandalWeb.BlogComponents
  alias Phoenix.PubSub

  @impl true
  def mount(%{"post_id" => post_id_str}, _session, socket) when is_connected?(socket) do
    :ok = PubSub.subscribe(Durandal.PubSub, "blog_posts")
    post = Blog.get_post!(post_id_str, preload: [:poster, :tags])
    Blog.increment_post_view_count(post.id)

    response =
      if socket.assigns.current_user do
        Blog.get_poll_response(socket.assigns.current_user.id, post.id)
      end

    socket
    |> assign(:post, post)
    |> assign(:response, response)
    |> assign(:site_menu_active, "blog")
    |> ok
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:post, nil)
    |> assign(:site_menu_active, "blog")
    |> ok
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
        new_post =
          struct(new_post, %{
            tags: post.tags,
            poster: post.poster
          })

        socket |> assign(:post, new_post)
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
    if assigns.current_user.id == post.poster_id || allow?(assigns.current_user, "admin") do
      Blog.delete_post(post)

      {:noreply,
       socket
       |> redirect(to: ~p"/blog")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("poll-choice", _, %{assigns: %{current_user: nil}} = socket) do
    socket
    |> noreply
  end

  def handle_event("poll-choice", %{"choice" => choice}, %{assigns: assigns} = socket) do
    response =
      if assigns[:response] do
        {:ok, response} = Blog.update_poll_response(assigns.response, %{"response" => choice})
        response
      else
        {:ok, response} =
          Blog.create_poll_response(%{
            "user_id" => assigns.current_user.id,
            "post_id" => assigns.post.id,
            "response" => choice
          })

        response
      end

    Durandal.Blog.PostLib.update_post_response_cache(assigns.post)

    socket
    |> assign(:response, response)
    |> noreply
  end
end
