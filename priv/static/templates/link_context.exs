  # Part1Part2s
  alias Durandal.Game.{Part1Part2, Part1Part2Lib, Part1Part2Queries}

  @doc false
  @spec part1_part2_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate part1_part2_query(args), to: Part1Part2Queries

  @doc section: :part1_part2
  @spec list_part1_part2s(Durandal.query_args()) :: [Part1Part2.t()]
  defdelegate list_part1_part2s(args), to: Part1Part2Lib

  @doc section: :part1_part2
  @spec get_part1_part2!(part1_id(), part2_id(), Durandal.query_args()) ::
          Part1Part2.t()
  defdelegate get_part1_part2!(part1_id, part2_id, query_args \\ []), to: Part1Part2Lib

  @doc section: :part1_part2
  @spec get_part1_part2(part1_id(), part2_id(), Durandal.query_args()) ::
          Part1Part2.t() | nil
  defdelegate get_part1_part2(part1_id, part2_id, query_args \\ []), to: Part1Part2Lib

  @doc section: :part1_part2
  @spec create_part1_part2(map) :: {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_part1_part2(attrs), to: Part1Part2Lib

  @doc section: :part1_part2s
  @spec create_many_part1_part2s([map]) ::
          {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_many_part1_part2s(attr_list), to: Part1Part2Lib

  @doc section: :part1_part2
  @spec update_part1_part2(Part1Part2, map) ::
          {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_part1_part2(part1_part2, attrs), to: Part1Part2Lib

  @doc section: :part1_part2
  @spec delete_part1_part2(Part1Part2.t()) ::
          {:ok, Part1Part2.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_part1_part2(part1_part2), to: Part1Part2Lib

  @doc section: :part1_part2
  @spec change_part1_part2(Part1Part2.t(), map) :: Ecto.Changeset.t()
  defdelegate change_part1_part2(part1_part2, attrs \\ %{}), to: Part1Part2Lib
