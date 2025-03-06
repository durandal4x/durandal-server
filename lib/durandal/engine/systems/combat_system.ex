defmodule Durandal.Engine.CombatSystem do
  @moduledoc """
  Moves objects based on their velocity
  """

  use Durandal.Engine.SystemMacro
  alias Durandal.Engine.Maths
  alias Durandal.Space

  def name(), do: "Combat"
  def stage(), do: :combat

  def combat_range(), do: 200

  @spec execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}
  def execute(universe_id) do
    universe_id
    |> find_targets()
    |> Enum.map(fn {shooter, target} ->
      perform_attack(shooter, target)
    end)
  end

  @spec find_targets(Durandal.universe_id()) :: [
          {Durandal.Space.Ship.t(), Durandal.Space.Ship.t()}
        ]
  def find_targets(universe_id) do
    # TODO Find a better way so we don't need to build this from scratch every tick
    ships = Space.list_ships(where: [universe_id: universe_id], preload: [:type])

    ships
    |> Enum.filter(fn ship ->
      ship.type.damage > 0
    end)
    |> Enum.map(fn origin_ship ->
      closest_target =
        ships
        |> Enum.filter(fn potential_target ->
          Enum.all?([
            potential_target.team_id != origin_ship.team_id,
            distance_to_target(origin_ship, potential_target) <= combat_range()
          ])
        end)
        |> Enum.map(fn potential_target ->
          {potential_target, distance_to_target(origin_ship, potential_target)}
        end)
        |> Enum.sort_by(fn {_, d} -> d end, &<=/2)
        |> head_or_nil

      if closest_target do
        {origin_ship, elem(closest_target, 0)}
      end
    end)
    |> Enum.reject(&is_nil(&1))
  end

  @doc """
  Pattern match allows us to calculate damage done based on shooter
  """
  def perform_attack(%Durandal.Space.Ship{} = origin, target) do
    apply_damage(target, origin.type.damage)
  end

  @doc """
  Pattern match allows us to apply damage based on target
  """
  def apply_damage(%Durandal.Space.Ship{id: target_id} = _target, amount) do
    # TODO group attacks together against ships so we can update them once per tick rather than once per attack
    # If the ship has been targeted by multiple attacks we might have a stale object
    target = Durandal.Space.get_ship(target_id, preload: [:type])

    if target do
      new_health = target.health - amount

      if new_health > 0 do
        {:ok, _} = Durandal.Space.update_ship(target, %{health: new_health})
      else
        Durandal.Space.delete_ship(target)
      end
    end
  end

  defp distance_to_target(ship1, ship2) do
    Maths.distance(ship1.position, ship2.position)
  end

  defp head_or_nil([]), do: nil
  defp head_or_nil([v | _]), do: v
end
