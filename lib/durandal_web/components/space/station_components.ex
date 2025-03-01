defmodule DurandalWeb.StationComponents do
  @moduledoc false
  use DurandalWeb, :component
  import DurandalWeb.{NavComponents}

  @doc """
  <DurandalWeb.StationComponents.filter_bar active="active" />

  <DurandalWeb.StationComponents.filter_bar active="active">
    Right side content here
  </DurandalWeb.StationComponents.filter_bar>
  """
  attr :selected, :string, default: "list"
  slot :inner_block, required: false

  def filter_bar(assigns) do
    ~H"""
    <div class="row section-menu">
      <div class="col">
        <.section_menu_button_url
          colour="info"
          icon={StylingHelper.icon(:list)}
          active={@selected == "list"}
          url={~p"/admin/stations"}
        >
          List
        </.section_menu_button_url>

        <.section_menu_button_url
          colour="info"
          icon={StylingHelper.icon(:new)}
          active={@selected == "new"}
          url={~p"/admin/stations/new"}
        >
          New
        </.section_menu_button_url>

        <.section_menu_button_url
          :if={@selected == "show"}
          colour="info"
          icon={StylingHelper.icon(:detail)}
          active={@selected == "show"}
          url="#"
        >
          Show
        </.section_menu_button_url>

        <.section_menu_button_url
          :if={@selected == "edit"}
          colour="info"
          icon={StylingHelper.icon(:edit)}
          active={@selected == "edit"}
          url="#"
        >
          Edit
        </.section_menu_button_url>
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
