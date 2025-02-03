defmodule Durandal.Repo.Migrations.EngineMigrations do
  use Ecto.Migration

  def change do
    alter table(:game_universes) do
      add :next_tick, :utc_datetime_usec
      add :tick_schedule, :string
    end
  end
end
