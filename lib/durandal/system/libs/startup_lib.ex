defmodule Durandal.System.StartupLib do
  @moduledoc false
  # Functionality executed during the Durandal startup process.

  alias Durandal.Settings

  @spec perform() :: any()
  def perform do
    user_settings()

    Settings.add_server_setting_type(%{
      key: "login.ip_rate_limit",
      label: "Login rate limit per IP",
      section: "Login",
      type: "integer",
      permissions: "Admin",
      default: 3,
      description:
        "The upper bound on how many failed attempts a given IP can perform before all further attempts will be blocked"
    })

    Settings.add_server_setting_type(%{
      key: "login.user_rate_limit",
      label: "Login rate limit per User",
      section: "Login",
      type: "integer",
      permissions: "Admin",
      default: nil,
      description:
        "The upper bound on how many failed attempts a given user can have before their logins are blocked."
    })
  end

  defp user_settings() do
    Settings.add_user_setting_type(%{
      key: "language",
      label: "Language",
      section: "interface",
      type: "string",
      permissions: nil,
      choices: ["English", "American", "Spanish", "Lojban", "Bork bork"],
      default: "English",
      description: "The language used in the interface"
    })

    Settings.add_user_setting_type(%{
      key: "timezone",
      label: "Timezone",
      section: "interface",
      type: "integer",
      permissions: nil,
      default: 0,
      description: "The timezone to convert all Times to.",
      validator: fn v ->
        if -12 <= v and v <= 14,
          do: :ok,
          else: {:error, "Timezone must be within -12 and +14 hours of UTC"}
      end
    })

    Settings.add_user_setting_type(%{
      key: "current_universe",
      label: "Universe",
      section: "active_game",
      type: "string",
      permissions: ["admin"],
      default: 0,
      description: "The universe currently selected",
      validator: fn v ->
        case Ecto.UUID.cast(v) do
          {:ok, _} -> :ok
          _ -> {:error, "Invalid UUID"}
        end
      end
    })

    Settings.add_user_setting_type(%{
      key: "current_team",
      label: "Team",
      section: "active_game",
      type: "string",
      permissions: ["admin"],
      default: 0,
      description: "The team currently selected",
      validator: fn v ->
        case Ecto.UUID.cast(v) do
          {:ok, _} -> :ok
          _ -> {:error, "Invalid UUID"}
        end
      end
    })
  end
end
