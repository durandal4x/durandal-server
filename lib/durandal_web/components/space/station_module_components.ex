defmodule DurandalWeb.StationModuleComponents do
  @moduledoc false
  use DurandalWeb, :component
  import DurandalWeb.{NavComponents}

  @doc """
  <DurandalWeb.StationModuleComponents.filter_bar active="active" />

  <DurandalWeb.StationModuleComponents.filter_bar active="active">
    Right side content here
  </DurandalWeb.StationModuleComponents.filter_bar>
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
          url={~p"/admin/station_modules"}
        >
          List
        </.section_menu_button_url>

        <.section_menu_button_url
          colour="info"
          icon={StylingHelper.icon(:new)}
          active={@selected == "new"}
          url={~p"/admin/station_modules/new"}
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
