defmodule DurandalWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use DurandalWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint DurandalWeb.Endpoint

      use DurandalWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import DurandalWeb.ConnCase
    end
  end

  setup tags do
    Durandal.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @spec auth(map()) :: map()
  def auth(data) do
    {:ok, user} =
      Durandal.Account.create_user(%{
        name: Durandal.uuid(),
        email: "#{Durandal.uuid()}@test",
        password: "password",
        groups: [],
        permissions: []
      })

    data
    |> Map.put(:user, user)
    |> log_in_user
  end

  @spec admin_auth(map()) :: map()
  def admin_auth(data) do
    {:ok, user} =
      Durandal.Account.create_user(%{
        name: Durandal.uuid(),
        email: "#{Durandal.uuid()}@test",
        password: "password",
        groups: ["admin"],
        permissions: ["admin"]
      })

    data
    |> Map.put(:user, user)
    |> log_in_user
  end

  @spec log_in_user(map()) :: map()
  defp log_in_user(%{conn: conn, user: user} = data) do
    {:ok, token} = Durandal.Account.create_user_token(user.id, "test", "test-user", "127.0.0.1")

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session(:user_token, token.identifier_code)

    %{data | conn: conn}
  end
end
