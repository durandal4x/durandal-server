defmodule Durandal.GameFixtures do
  @moduledoc false
  alias Durandal.Game.Universe

  @spec universe_fixture(map) :: Universe.t()
  def universe_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Universe.changeset(
      %Universe{},
      %{
        name: data["name"] || "universe_name_#{r}",
        active?: data["active?"] || false
      }
    )
    |> Durandal.Repo.insert!()
  end
end
