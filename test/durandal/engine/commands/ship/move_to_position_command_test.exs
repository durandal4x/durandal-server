# defmodule Durandal.Engine.Commands.ShipMoveToPositionCommandTest do
#   use Durandal.SimCase
#   alias Durandal.Engine.ShipMoveToPositionCommand
#   alias Durandal.{Space, Player}

#   test "test move to position" do
#     universe = start_universe("empty", [])

#     team = team_fixture(%{"universe_id" => universe.id})
#     system = system_fixture(%{"universe_id" => universe.id})
#     user = user_fixture()

#     team_member_fixture(%{
#       "user_id" => user.id,
#       "team_id" => team.id
#     })

#     ship_type = ship_type_fixture(%{
#       "universe_id" => universe.id,
#       "acceleration" => 10
#     })

#     ship =
#       ship_fixture(%{
#         "system_id" => system.id,
#         "team_id" => team.id,
#         "type_id" => ship_type.id,
#         "position" => [0, 0, 0],
#         "velocity" => [0, 0, 0]
#       })

#     command = command_fixture(%{
#       "command_type" => ShipMoveToPositionCommand.name(),
#       "subject_type" => "ship",
#       "subject_id" => ship.id,
#       "ordering" => 0,
#       "team_id" => team.id,
#       "user_id" => user.id,
#       "contents" => %{
#         "position" => [10_000, -10_000, 0]
#       }
#     })

#     # A second command, to ensure we're grabbing the correct one
#     spare_command = command_fixture(%{
#       "command_type" => ShipMoveToPositionCommand.name(),
#       "subject_type" => "ship",
#       "subject_id" => ship.id,
#       "ordering" => 1,
#       "team_id" => team.id,
#       "user_id" => user.id,
#       "contents" => %{
#         "position" => [0, 0, 0]
#       }
#     })

#     ship = Space.get_ship!(ship.id)
#     assert ship.velocity == [0, 0, 0]
#     assert ship.position == [0, 0, 0]
#     assert ship.universe_id == universe.id

#     tick_universe(universe.id)

#     ship = Space.get_ship!(ship.id)
#     assert ship.velocity == [7, -7, 0]
#     assert ship.position == [7, -7, 0]

#     # If we tick again we should be going even faster!
#     tick_universe(universe.id)

#     ship = Space.get_ship!(ship.id)
#     assert ship.velocity == [14, -14, 0]
#     assert ship.position == [21, -21, 0]

#     # Tick 10 times, we're on the way there
#     tick_universe(universe.id, 10)

#     ship = Space.get_ship!(ship.id)
#     assert ship.velocity == [84, -84, 0]
#     assert ship.position == [546, -546, 0]

#     command = Player.get_command!(command.id)
#     assert command.contents == %{"phase" => "accelerate", "position" => [10_000, -10_000, 0]}

#     # Spare command should not have changed
#     spare_command = Player.get_command!(spare_command.id)
#     assert spare_command.contents == %{"position" => [0, 0, 0]}

#     # Another 30, should be slowing down now
#     tick_universe(universe.id, 30)

#     ship = Space.get_ship!(ship.id)
#     assert ship.velocity == [258, -258, 0]
#     assert ship.position == [6249, -6249, 0]

#     command = Player.get_command!(command.id)
#     assert command.contents == %{"phase" => "stop", "position" => [10_000, -10_000, 0]}

#     tick_universe(universe.id, 100)
#     ship = Space.get_ship!(ship.id)
#     assert ship.velocity == [0, 0, 0]
#     assert ship.position == [10_000, -10_000, 0]

#     tear_down(universe.id)
#   end
# end
