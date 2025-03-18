defmodule DurandalWeb.Blog.PostFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component
  alias Durandal.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <style type="text/css">
        .tag-selector {
          cursor: pointer;
          border: 1px solid #FFF;
          font-size: 1em;
        }
      </style>

      <h3>
        {@title}
      </h3>

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="post-form">
        <div class="row mb-4">
          <div class="col-md-12 col-lg-8 col-xl-6">
            <label for="post_title" class="control-label">Title:</label>
            <.input field={@form[:title]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />

            <label for="post_contents" class="control-label">Summary:</label>
            <em class="float-end">Plain text, 1-3 lines</em>
            <textarea
              name="post[summary]"
              id="post_summary"
              rows="3"
              phx-debounce="100"
              class="form-control"
            ><%= @form[:summary].value %></textarea>
            <br />

            <label for="post_contents" class="control-label">Contents:</label>
            <span class="float-end monospace">
              <span style="font-size: 1.2em; font-weight: bold;"># Heading</span>
              &nbsp;&nbsp; <em>__italic__</em>
              &nbsp;&nbsp; <strong>**bold**</strong>
              &nbsp;&nbsp;
              - List item
              &nbsp;&nbsp;
              [Link text](url)
            </span>
            <textarea
              name="post[contents]"
              id="post_contents"
              rows="12"
              phx-debounce="100"
              class="form-control"
            ><%= @form[:contents].value %></textarea>
          </div>
          <div class="col">
            <h4>Tags ({Enum.count(@selected_tags)})</h4>
            <%= for tag <- @tags do %>
              <%= if Enum.member?(@selected_tags, tag.id) do %>
                <span
                  class="badge rounded-pill m-1 tag-selector"
                  style={"background-color: #{tag.colour}; border-color: rgba(0,0,0,255); border-width: 2px;"}
                  phx-click="toggle-selected-tag"
                  phx-value-tag={tag.id}
                  phx-target={@myself}
                  id={"tag-#{tag.id}"}
                >
                  <Fontawesome.icon icon={tag.icon} style="solid" />
                  {tag.name}
                </span>
              <% else %>
                <span
                  class="badge rounded-pill m-1 tag-selector"
                  style={"background-color: #{tag.colour}; border-color: rgba(0,0,0,0); border-width: 2px;"}
                  phx-click="toggle-selected-tag"
                  phx-value-tag={tag.id}
                  phx-target={@myself}
                  id={"tag-#{tag.id}"}
                >
                  <Fontawesome.icon icon={tag.icon} style="regular" />
                  {tag.name}
                </span>
              <% end %>
            <% end %>
          </div>
          <div class="col">
            <h4>Poll</h4>
            <.input
              field={@form[:poll_choices]}
              type="textarea-array"
              phx-debounce="100"
              label="Poll choices"
              rows="12"
            />
          </div>
        </div>

        <% disabled = if not @form.source.valid? or Enum.empty?(@selected_tags), do: "disabled" %>
        <%= if @post.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/blog/show/#{@post.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class={"btn btn-primary btn-block #{disabled}"} type="submit">
                Update post
              </button>
            </div>
          </div>
        <% else %>
          <button class={"btn btn-primary btn-block #{disabled}"} type="submit">Post</button>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    tags =
      Blog.list_tags(
        order_by: [
          "Name (A-Z)"
        ]
      )

    changeset = Blog.change_post(post)

    socket
    |> assign(:tags, tags)
    |> assign(:selected_tags, assigns[:selected_tags] || [])
    |> assign(:originally_selected_tags, assigns[:selected_tags] || [])
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    post_params =
      Map.merge(post_params, %{
        "poster_id" => socket.assigns.current_user.id
      })

    changeset =
      socket.assigns.post
      |> Blog.change_post(post_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    socket
    |> assign_form(changeset)
    |> noreply
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    post_params =
      Map.merge(post_params, %{
        "poster_id" => socket.assigns.current_user.id
      })

    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("toggle-selected-tag", %{"tag" => tag_id}, socket) do
    new_selected_tags =
      if Enum.member?(socket.assigns.selected_tags, tag_id) do
        List.delete(socket.assigns.selected_tags, tag_id)
      else
        [tag_id | socket.assigns.selected_tags] |> Enum.uniq()
      end

    {:noreply,
     socket
     |> assign(:selected_tags, new_selected_tags)}
  end

  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        deleted_tags =
          socket.assigns.originally_selected_tags
          |> Enum.reject(fn tag_id ->
            Enum.member?(socket.assigns.selected_tags, tag_id)
          end)

        Blog.delete_post_tags(post.id, deleted_tags)

        added_tags =
          socket.assigns.selected_tags
          |> Enum.reject(fn tag_id ->
            Enum.member?(socket.assigns.originally_selected_tags, tag_id)
          end)
          |> Enum.map(fn tag_id ->
            %{
              tag_id: tag_id,
              post_id: post.id
            }
          end)

        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Durandal.Blog.PostTag, added_tags)
        |> Durandal.Repo.transaction()

        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    post_params =
      Map.merge(post_params, %{
        "poster_id" => socket.assigns.current_user.id
      })

    case Blog.create_post(post_params) do
      {:ok, post} ->
        post_tags =
          socket.assigns.selected_tags
          |> Enum.map(fn tag_id ->
            %{
              tag_id: tag_id,
              post_id: post.id
            }
          end)

        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Durandal.Blog.PostTag, post_tags)
        |> Durandal.Repo.transaction()

        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
