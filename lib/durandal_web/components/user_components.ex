defmodule DurandalWeb.UserComponents do
  @moduledoc false
  use DurandalWeb, :component
  import DurandalWeb.{NavComponents}

  @doc """
  <DurandalWeb.UserComponents.filter_bar active="active" />

  <DurandalWeb.UserComponents.filter_bar active="active">
    Right side content here
  </DurandalWeb.UserComponents.filter_bar>
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
          url={~p"/admin/accounts"}
        >
          List
        </.section_menu_button_url>

        <.section_menu_button_url
          colour="info"
          icon={StylingHelper.icon(:new)}
          active={@selected == "new"}
          url={~p"/admin/accounts/user/new"}
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

  @doc """
  <DurandalWeb.UserComponents.status_icon user={user} />
  """
  def status_icon(%{user: %{data: user_data} = user} = assigns) do
    restrictions = user_data["restrictions"] || []

    ban_status =
      cond do
        Enum.member?(restrictions, "Permanently banned") -> "banned"
        Enum.member?(restrictions, "Login") -> "suspended"
        true -> ""
      end

    icons =
      [
        if(assigns.user.smurf_of_id != nil,
          do: {"primary", "fa-smurf"}
        ),
        if(Enum.member?(user.roles, "Smurfer"), do: {"info2", "fa-solid fa-split"}),
        if(ban_status == "banned",
          do: {"danger2", "fa-ban"}
        ),
        if(ban_status == "suspended",
          do: {"danger", "fa-suspend"}
        ),
        if(Enum.member?(restrictions, "All chat"),
          do: {"danger", "fa-mute"}
        ),
        if(Enum.member?(restrictions, "Warning reminder"),
          do: {"warning", "fa-warn"}
        ),
        if(Enum.member?(user.roles, "Trusted"), do: {"", "fa-solid fa-check"}),
        if(not Enum.member?(user.roles, "Verified"),
          do: {"info", "fa-solid fa-square-question"}
        )
      ]
      |> Enum.reject(&(&1 == nil))

    status_icon_list(%{icons: icons})
  end

  defp status_icon_list(assigns) do
    ~H"""
    <div :for={{colour, icon} <- @icons} class="d-inline-block">
      <i class={"fa-fw text-#{colour} #{icon}"}></i>
    </div>
    """
  end

  @doc """
  <DurandalWeb.UserComponents.recents_dropdown current_user={@current_user} />
  """
  attr :current_user, :map, required: true

  def recents_dropdown(assigns) do
    # recents =
    #   assigns[:current_user]
    #   |> Durandal.Account.RecentlyUsedCache.get_recently()
    #   |> Enum.take(15)

    recents = []

    assigns =
      assigns
      |> assign(recents: recents)

    ~H"""
    <div :if={not Enum.empty?(@recents)} class="nav-item dropdown mx-2">
      <a
        class="dropdown-toggle dropdown-toggle-icon-only"
        href="#"
        data-bs-toggle="dropdown"
        aria-haspopup="true"
        aria-expanded="false"
        id="user-recents-link"
      >
        <i class="fa-solid fa-clock fa-fw fa-lg"></i>
      </a>
      <div
        class="dropdown-menu dropdown-menu-end"
        aria-labelledby="user-recents-link"
        style="min-width: 300px; max-width: 500px;"
      >
        <span class="dropdown-header" style="font-weight: bold;">
          Recent items
        </span>

        <a :for={r <- @recents} class="dropdown-item" href={r.url}>
          <Fontawesome.icon icon={r.type_icon} style="regular" css={"color: #{r.type_colour}"} />

          <%= if r.item_icon do %>
            <Fontawesome.icon icon={r.item_icon} style="regular" css={"color: #{r.item_colour}"} />
          <% else %>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <% end %>
          &nbsp; {r.item_label}
        </a>
      </div>
    </div>
    """
  end
end
