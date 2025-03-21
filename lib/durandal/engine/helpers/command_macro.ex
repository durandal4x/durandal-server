defmodule Durandal.Engine.CommandMacro do
  @moduledoc """
  Behaviour and boilerplate for Durandal engine systems.

  Apply with `use Durandal.Engine.CommandMacro`
  """

  @doc """
  The subjects this command applies to
  """
  @callback category() :: String.t()

  @doc """
  The name of the system, used internally and passed to translation for rendering.
  """
  @callback name() :: String.t()

  @doc """
  Given a set of params, parse the values to make appropriate contents.
  """
  @callback parse(map()) :: {:ok, map()} | {:error, String.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Durandal.Engine.CommandMacro
      require Logger
    end
  end
end
