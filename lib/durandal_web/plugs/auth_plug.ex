defmodule DurandalWeb.AuthPlug do
  @moduledoc false
  alias DurandalWeb.UserAuth
  use DurandalWeb, :verified_routes
  require Logger

  def init(_opts) do
    # Keyword.fetch!(opts, :repo)
  end

  def call(conn, opts) do
    conn = UserAuth.fetch_current_user(conn, opts)

    if conn.assigns[:current_user] != nil do
      Logger.metadata([user_id: conn.assigns[:current_user].id] ++ Logger.metadata())
    end

    if banned_user?(conn) do
      UserAuth.log_out_user(conn)
    else
      conn
    end
  end

  defp banned_user?(%{assigns: %{current_user: nil}}), do: false

  defp banned_user?(%{assigns: %{current_user: _current_user}} = _conn_or_socket) do
    false
  end
end
