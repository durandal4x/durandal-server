# defmodule Durandal.Engine.ShipMoveToPositionCommand do
#   @moduledoc """

#   """
#   use Durandal.Engine.CommandMacro
#   alias Durandal.{Space, Player}
#   alias Durandal.Engine.{Maths, Physics}

#   def category(), do: "ship"
#   def name(), do: "move_to_position"

#   @spec parse(map()) :: {:ok, map()} | {:error, String.t()}
#   def parse(params) do
#     Map.merge(params, %{
#       "position" => Enum.map(params["position"], &String.to_integer/1)
#     })
#   end

#   defp first_evaluation(%{contents: %{"phase" => _}} = command), do: command

#   defp first_evaluation(command) do
#     {:ok, c} =
#       Player.update_command(command, %{
#         contents: Map.put(command.contents, "phase", "accelerate")
#       })

#     c
#   end

#   @spec execute(map(), Durandal.Player.Command.t()) :: map()
#   def execute(context, command) do
#     command = first_evaluation(command)

#     case Space.get_ship(command.subject_id, preload: [:type]) do
#       nil ->
#         context

#       ship ->
#         do_execute(context, command, ship)
#     end
#   end

#   defp do_execute(context, %{contents: %{"phase" => "stop"}} = command, ship) do
#     Engine.add_action(context, command.subject_id, [:velocity], %{
#       ship_id: command.subject_id,
#       direction: :stop
#     })
#   end

#   defp do_execute(context, command, ship) do
#     target_coords = command.contents["position"]
#     distance_to_target = Maths.distance(ship.position, target_coords)

#     target_close = distance_to_target < ship.type.acceleration * 10
#     absolute_velocity = Maths.distance(ship.velocity)

#     cond do
#       target_close && absolute_velocity == 0 ->
#         IO.puts("")
#         IO.inspect("ARRIVAL", label: "#{__MODULE__}:#{__ENV__.line}")
#         IO.puts("")

#       # target_close ->
#       #   # If we're really close, we just want to stop
#       #   context
#       #   |> Engine.add_action(command.subject_id, [:velocity], %{
#       #     ship_id: command.subject_id,
#       #     direction: :stop
#       #   })
#       #   |> Engine.defer_update_command(command.id, %{"phase" => "stop"})

#       true ->
#         do_decelerate? = Physics.decelerate?(ship, target_coords)
#         target_direction = Maths.calculate_angle(ship.position, command.contents["position"])

#         # The acceleration we will be applying
#         actual_direction =
#           if do_decelerate? do
#             context
#             |> Engine.add_action(command.subject_id, [:velocity], %{
#               ship_id: command.subject_id,
#               direction: :stop
#             })
#             |> Engine.defer_update_command(command.id, %{"phase" => "stop"})
#           else
#             Engine.add_action(context, command.subject_id, [:velocity], %{
#               ship_id: command.subject_id,
#               direction: target_direction
#             })
#           end
#     end
#   end
# end
