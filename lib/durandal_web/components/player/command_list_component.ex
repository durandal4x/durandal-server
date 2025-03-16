defmodule DurandalWeb.Player.CommandListComponent do
  @moduledoc """
  <.live_component
    id={:commands}
    module={DurandalWeb.Player.CommandListComponent}
    commands={@commands}
  />


  <.live_component
    id={:commands}
    module={DurandalWeb.Player.CommandListComponent}
    commands={@commands}
  >
    Post commands content here
  </.live_component>
  """
  use DurandalWeb, :live_component
  alias Durandal.Player
  alias Durandal.Player.CommandLib

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :for={command <- @commands}>
        <span>{command.command_type}</span>
        &nbsp;&nbsp;&nbsp;
        <span>{inspect command.contents}</span>
      </div>
      <br />
      {if assigns[:inner_block], do: render_slot(@inner_block)}
    </div>
    """
  end

  def mount(socket) do
    form = to_form(%{}, as: "command")
    {:ok, assign(socket, form: form)}
  end

  @impl true
  def update(assigns, socket) do
    assigns = assigns
      |> update_assign(:subject_type)
      |> update_assign(:command_types)

    socket
    |> assign(assigns)
    |> ok
  end

  defp update_assign(%{subject: %Durandal.Space.Ship{} = ship} = assigns, :subject_type) do
    Map.merge(assigns, %{
      subject_type: "ship",
      subject_id: ship.id
    })
  end

  defp update_assign(%{subject: %Durandal.Space.Station{} = station} = assigns, :subject_type) do
    Map.merge(assigns, %{
      subject_type: "station",
      subject_id: station.id
    })
  end

  defp update_assign(%{subject_type: subject_type} = assigns, :command_types) do
    Map.put(assigns, :command_types, CommandLib.command_types(subject_type))
  end

  defp update_assign(assigns, _), do: assigns
end
