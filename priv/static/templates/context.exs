  # Objects
  alias Durandal.Context.{Object, ObjectLib, ObjectQueries}

  @doc false
  @spec object_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate object_query(args), to: ObjectQueries

  @doc section: :object
  @spec list_objects(Durandal.query_args()) :: [Object.t]
  defdelegate list_objects(args), to: ObjectLib

  @doc section: :object
  @spec get_object!(Object.id(), Durandal.query_args()) :: Object.t
  defdelegate get_object!(object_id, query_args \\ []), to: ObjectLib

  @doc section: :object
  @spec get_object(Object.id(), Durandal.query_args()) :: Object.t | nil
  defdelegate get_object(object_id, query_args \\ []), to: ObjectLib

  @doc section: :object
  @spec create_object(map) :: {:ok, Object.t} | {:error, Ecto.Changeset.t()}
  defdelegate create_object(attrs), to: ObjectLib

  @doc section: :object
  @spec update_object(Object, map) :: {:ok, Object.t} | {:error, Ecto.Changeset.t()}
  defdelegate update_object(object, attrs), to: ObjectLib

  @doc section: :object
  @spec delete_object(Object.t) :: {:ok, Object.t} | {:error, Ecto.Changeset.t()}
  defdelegate delete_object(object), to: ObjectLib

  @doc section: :object
  @spec change_object(Object.t, map) :: Ecto.Changeset.t()
  defdelegate change_object(object, attrs \\ %{}), to: ObjectLib
