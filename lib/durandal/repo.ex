defmodule Durandal.Repo do
  use Ecto.Repo,
    otp_app: :durandal,
    adapter: Ecto.Adapters.Postgres
end
