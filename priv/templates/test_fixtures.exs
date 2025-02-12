
  alias Durandal.Context.$Object

  @spec $object_fixture(map) :: $Object.t()
  def $object_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    $Object.changeset(
      %$Object{},
      %{
        # $OBJECT FIELDS
      }
    )
    |> Durandal.Repo.insert!()
  end
