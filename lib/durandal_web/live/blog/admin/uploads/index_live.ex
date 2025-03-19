defmodule DurandalWeb.Admin.Blog.UploadLive.Index do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Blog

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    user_uploads =
      Blog.list_uploads(
        where: [uploader_id: socket.assigns.current_user.id],
        order_by: ["Newest first"]
      )

    socket
    |> stream(:user_uploads, user_uploads)
    |> ok
  end

  def mount(_params, _session, socket) do
    socket
    |> stream(:user_uploads, [])
    |> ok
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    upload = Blog.get_upload!(id)

    cond do
      upload.uploader_id != socket.assigns.current_user.id ->
        raise "Not your upload"

      true ->
        Blog.delete_upload(upload)
    end

    socket
    |> stream_delete(:user_uploads, %{id: id})
    |> noreply
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> apply_action(socket.assigns.live_action, params)
    |> noreply
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Blog admin page")
    |> assign(:post, %{})
    |> assign(:site_menu_active, "blog")
  end
end
