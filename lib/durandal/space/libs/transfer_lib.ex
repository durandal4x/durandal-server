defmodule Durandal.Space.TransferLib do
  @moduledoc """
  Common operations for ShipTransfer and StationTransfer
  """
  alias Durandal.Engine.Maths

  @doc """
  Given two objects with position, calculated the distance between them.
  """
  @spec calculate_distance(Durandal.positional_entity(), Durandal.positional_entity()) ::
          non_neg_integer()
  def calculate_distance(%{position: from_position}, %{position: to_position}) do
    Maths.distance(from_position, to_position)
    |> round()
  end

  @doc """
  Given two vector points and a percentage, calculate a midpoint from the origin to the destination
  based on the percentage
  """
  @spec calculate_midpoint(Maths.vector(), Maths.vector(), number()) :: Maths.vector()
  def calculate_midpoint(origin, destination, progress_percentage) do
    origin
    |> Enum.zip(destination)
    |> Enum.map(fn {o, d} ->
      round(o + (d - o) * progress_percentage)
    end)
  end

  def calculate_progress_percentage(progress, distance) do
    100 * (progress / max(distance, 1))
  end
end
