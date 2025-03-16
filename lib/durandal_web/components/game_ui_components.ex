defmodule DurandalWeb.GameUIComponents do
  @moduledoc false
  use DurandalWeb, :component
  # import DurandalWeb.{NavComponents}

  @doc """
  <DurandalWeb.GameUIComponents.game_nav_bar active="active" />

  <DurandalWeb.GameUIComponents.game_nav_bar active="active">
    Right side content here
  </DurandalWeb.GameUIComponents.game_nav_bar>
  """
  attr :selected, :string, default: "list"
  attr :current_universe, :map, required: true
  attr :current_team, :map, required: true
  attr :current_user, :map, required: true
  slot :inner_block, required: false

  def game_nav_bar(assigns) do
    ~H"""
    <div class="row">
      <div class="col m-1">
        <.nav_button_url
          colour="secondary"
          icon={"home"}
          active={@selected == "home"}
          url={~p"/team"}
        >
          Home
        </.nav_button_url>

        <.nav_button_url
          colour="secondary"
          icon={"globe"}
          active={@selected == "dashboard"}
          url={~p"/team/dashboard"}
        >
          Dashboard
        </.nav_button_url>

        {render_slot(@inner_block)}

        <div class="float-end">
          <%= if assigns[:current_universe] do %>
            <%= if assigns[:current_team] do %>
              <span
                class="badge rounded-pill text-bg-info p-2 mx-1"
              >
                <Fontawesome.icon icon="users" style="solid" />
                {@current_team.name}
              </span>
            <% end %>

            <span
              class="badge rounded-pill text-bg-info2 p-2 mx-1"
            >
              <Fontawesome.icon icon="galaxy" style="solid" />
              {@current_universe.name}
            </span>
          <% end %>

          <DurandalWeb.NavComponents.recents_dropdown current_user={@current_user} />
          <DurandalWeb.NavComponents.account_dropdown current_user={@current_user} />
        </div>
      </div>
    </div>
    """
  end


  @doc """
  <.nav_button colour={colour} icon={lib} active={true/false} phx-action="do-something">
    Text goes here
  </.nav_button>
  """
  attr :icon, :string, default: nil
  attr :colour, :string, default: "secondary"
  attr :active, :boolean, default: false
  slot :inner_block, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the button"

  def nav_button(assigns) do
    assigns =
      assigns
      |> assign(:active_class, if(assigns[:active], do: "active"))

    ~H"""
    <div class={"btn btn-sm btn-outline-#{@colour} #{@active_class}"} {@rest}>
      <Fontawesome.icon :if={@icon} icon={@icon} style={if @active, do: "solid", else: "regular"} />
      &nbsp; {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  <.nav_button_url colour={colour} icon={lib} active={true/false} url={url}>
    Text goes here
  </.nav_button_url>
  """
  attr :icon, :string, default: nil
  attr :url, :string, default: nil
  attr :colour, :string, default: "secondary"
  attr :active, :boolean, default: false
  slot :inner_block, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the button"

  def nav_button_url(assigns) do
    assigns =
      assigns
      |> assign(:active_class, if(assigns[:active], do: "active"))

    ~H"""
    <.link navigate={@url} class={"btn btn-sm btn-outline-#{@colour} #{@active_class}"} {@rest}>
      <Fontawesome.icon :if={@icon} icon={@icon} style={if @active, do: "solid", else: "regular"} />
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
