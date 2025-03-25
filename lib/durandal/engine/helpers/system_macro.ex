defmodule Durandal.Engine.SystemMacro do
  @moduledoc """
  Behaviour and boilerplate for Durandal engine systems.

  Apply with `use Durandal.Engine.SystemMacro`
  """

  @doc """
  The name of the system
  """
  @callback name() :: String.t()

  @doc """
  The item from Durandal.Engine.evaluation_stages this system is executed as part of
  """
  @callback stage() :: atom

  @doc """
  The meat of the system, this allows the system to update the state of the game as part of its update.
  """
  @callback execute(Durandal.universe_id()) :: :ok | {:error, [String.t()]}

  defmacro __using__(_opts) do
    quote do
      @behaviour Durandal.Engine.SystemMacro
      alias Durandal.Engine
      require Logger

      # alias Durandal.Engine.TypeConvertors

      # @spec execute(any(), Durandal.ConnState.t()) :: Durandal.handler_System()
      # def generate(data, state) do
      #   {result, new_state} =
      #     :telemetry.span(
      #       [:Durandal, :protocol, :System],
      #       %{name: name()},
      #       fn ->
      #         r = do_generate(data, state)
      #         {r, %{name: name()}}
      #       end
      #     )

      #   {%{"name" => name(), "message" => result}, new_state}
      # end
    end
  end
end
