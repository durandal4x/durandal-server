defmodule DurandalWeb.Blog.TagFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component

  alias Durandal.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <hr />
      <h3>
        {@title}
      </h3>

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="tag-form">
        <div class="row mb-4">
          <div class="col">
            <label for="tag_name" class="control-label">Name</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
          </div>

          <div class="col">
            <label for="tag_colour" class="control-label">Colour</label>
            <.input field={@form[:colour]} type="color" phx-debounce="100" />
          </div>

          <div class="col">
            <label for="tag_icon" class="control-label">Icon</label>
            <Fontawesome.icon icon={@form[:icon].value} style="solid" />
            <.input field={@form[:icon]} type="text" phx-debounce="100" />
          </div>
        </div>

        <% disabled = if not @form.source.valid?, do: "disabled" %>
        <%= if @tag.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/blog/tags"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class={"btn btn-primary btn-block #{disabled}"} type="submit">
                Update tag
              </button>
            </div>
          </div>
        <% else %>
          <button class={"btn btn-primary btn-block #{disabled}"} type="submit">Create tag</button>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{tag: tag} = assigns, socket) do
    changeset = Blog.change_tag(tag)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"tag" => tag_params}, socket) do
    changeset =
      socket.assigns.tag
      |> Blog.change_tag(tag_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    save_tag(socket, socket.assigns.action, tag_params)
  end

  defp save_tag(socket, :edit, tag_params) do
    case Blog.update_tag(socket.assigns.tag, tag_params) do
      {:ok, tag} ->
        notify_parent({:saved, tag})

        {:noreply,
         socket
         |> put_flash(:info, "Tag updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_tag(socket, :new, tag_params) do
    case Blog.create_tag(tag_params) do
      {:ok, tag} ->
        notify_parent({:saved, tag})

        {:noreply,
         socket
         |> put_flash(:info, "Tag created successfully")
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
