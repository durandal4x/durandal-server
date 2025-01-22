  # $Objects
  alias Durandal.$Context.{$Object, $ObjectLib, $ObjectQueries}

  @doc false
  @spec $object_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate $object_query(args), to: $ObjectQueries

  @doc section: :$object
  @spec list_$objects(Durandal.query_args()) :: [$Object.t()]
  defdelegate list_$objects(args), to: $ObjectLib

  @doc section: :$object
  @spec get_$object!($Object.id(), Durandal.query_args()) :: $Object.t()
  defdelegate get_$object!($object_id, query_args \\ []), to: $ObjectLib

  @doc section: :$object
  @spec get_$object($Object.id(), Durandal.query_args()) :: $Object.t() | nil
  defdelegate get_$object($object_id, query_args \\ []), to: $ObjectLib

  @doc section: :$object
  @spec create_$object(map) :: {:ok, $Object.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_$object(attrs), to: $ObjectLib

  @doc section: :$object
  @spec update_$object($Object, map) :: {:ok, $Object.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_$object($object, attrs), to: $ObjectLib

  @doc section: :$object
  @spec delete_$object($Object.t()) :: {:ok, $Object.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_$object($object), to: $ObjectLib

  @doc section: :$object
  @spec change_$object($Object.t(), map) :: Ecto.Changeset.t()
  defdelegate change_$object($object, attrs \\ %{}), to: $ObjectLib
