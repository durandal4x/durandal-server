defmodule DurandalWeb.Blog.PostFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component
  alias Durandal.Blog

  @impl true
  def render(assigns) do
    show_upload_form = Map.get(assigns, :show_upload_form, false)

    assigns =
      assigns
      |> assign(:show_upload_form, show_upload_form)

    ~H"""
    <div>
      <style type="text/css">
        .tag-selector {
          cursor: pointer;
          border: 1px solid #FFF;
          font-size: 1em;
        }
      </style>

      <span
        :if={@uploads_enabled && not @show_upload_form}
        class="btn btn-info float-end"
        phx-click="show-upload-form"
        phx-target={@myself}
      >
        <Fontawesome.icon icon="upload" style="solid" /> Show upload interface
      </span>

      <div :if={@uploads_enabled && @show_upload_form}>
        <span class="btn btn-info float-end" phx-click="hide-upload-form" phx-target={@myself}>
          <Fontawesome.icon icon="times" style="solid" /> Close upload interface
        </span>

        <form
          id="upload-form"
          phx-submit="save-upload"
          phx-change="validate-upload"
          phx-target={@myself}
        >
          <.live_file_input upload={@uploads.blog_file} />
          <button class="btn btn-primary" type="submit">
            <Fontawesome.icon icon="upload" style="solid" /> Upload
          </button>
        </form>

        <section phx-drop-target={@uploads.blog_file.ref}>
          <%!-- render each blog_file entry --%>
          <article
            :for={entry <- @uploads.blog_file.entries}
            class="upload-entry d-inline-block my-1 mx-2"
          >
            <figure>
              <.live_img_preview entry={entry} style="max-width: 200px; max-height: 200px;" />
              <figcaption>{entry.client_name}</figcaption>
            </figure>

            <%!-- entry.progress will update automatically for in-flight entries --%>
            <div class="progress" style="height: 10px;">
              <div
                class="progress-bar"
                role="progressbar"
                aria-label="Basic example"
                style={"width: #{entry.progress}%;"}
                aria-valuenow={entry.progress}
                aria-valuemin="0"
                aria-valuemax="100"
              >
              </div>
            </div>

            <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
            <button
              class="btn btn-sm btn-danger"
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              phx-target={@myself}
            >
              &times;
            </button>

            <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
            <p :for={err <- upload_errors(@uploads.blog_file, entry)} class="alert alert-danger">
              {error_to_string(err)}
            </p>
          </article>

          <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
          <p :for={err <- upload_errors(@uploads.blog_file)} class="alert alert-danger">
            {error_to_string(err)}
          </p>
        </section>

        <br />
        <div :for={upload <- @recent_uploads} class="d-inline-block" style="width: 200px;">
          <img src={~p"/blog/upload/#{upload.id}"} style="max-width: 200px; max-height: 200px;" />
          <input type="text" value={"![image](/blog/upload/#{upload.id})"} class="form-control" />
        </div>

        <hr />
      </div>

      <h3>
        {@title}
      </h3>

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="post-form">
        <div class="row mb-4">
          <div class="col-md-12 col-lg-8 col-xl-6">
            <.input
              field={@form[:title]}
              type="text"
              autofocus="autofocus"
              phx-debounce="100"
              label="Title:"
            />
            <br />

            <.input
              field={@form[:summary]}
              type="textarea"
              phx-debounce="100"
              label="Summary:"
              rows="3"
            />
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
            <.input field={@form[:contents]} type="textarea" phx-debounce="100" rows="12" />
            <br />

            <.input
              field={@form[:url_slug]}
              type="text"
              phx-debounce="100"
              label="URL slug key (optional)"
            />
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
              <a
                href={~p"/blog/show/#{@post.url_slug || @post.id}"}
                class="btn btn-secondary btn-block"
              >
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

    recent_uploads =
      Blog.list_uploads(
        where: [
          uploader_id: assigns[:current_user].id
        ],
        order_by: ["Newest first"],
        limit: 6
      )

    socket
    |> assign(:uploads_enabled, Application.get_env(:durandal, :blog_allow_upload))
    |> assign(:tags, tags)
    |> assign(:selected_tags, assigns[:selected_tags] || [])
    |> assign(:originally_selected_tags, assigns[:selected_tags] || [])
    |> assign(:recent_uploads, recent_uploads)
    |> assign(:uploaded_files, [])
    |> allow_upload(:blog_file, accept: ~w(.jpg .jpeg .png), max_entries: 2)
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :blog_file, ref)}
  end

  def handle_event("validate-upload", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save-upload", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :blog_file, fn %{path: path}, entry ->
        folder =
          Application.get_env(:durandal, :blog_upload_path)
          |> String.replace("$app_dir", Application.app_dir(:durandal))

        dest = Path.join(folder, Path.basename(path))
        stat = File.stat!(path)

        # Copy the file over
        File.cp!(path, dest)

        upload_result =
          Blog.create_upload(%{
            uploader_id: socket.assigns.current_user.id,
            filename: dest,
            type: entry.client_type,
            file_size: stat.size,
            contents: ""
          })

        case upload_result do
          {:ok, upload} ->
            {:ok, upload}

          err ->
            err
        end
      end)

    {:noreply, update(socket, :recent_uploads, &((uploaded_files ++ &1) |> Enum.take(5)))}
  end

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

  def handle_event("show-upload-form", _, socket) do
    socket
    |> assign(:show_upload_form, true)
    |> noreply
  end

  def handle_event("hide-upload-form", _, socket) do
    socket
    |> assign(:show_upload_form, false)
    |> noreply
  end

  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(socket.assigns.post, post_params, :update) do
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
