defmodule Durandal.Helpers.PubSubHelper do
  @moduledoc false
  alias Phoenix.PubSub

  @doc false
  @spec broadcast(String.t(), map()) :: :ok
  def broadcast(topic, %{event: _} = message) do
    PubSub.broadcast(
      Durandal.PubSub,
      topic,
      Map.put(message, :topic, topic)
    )
  end

  @spec subscribe(String.t()) :: :ok
  def subscribe(topic) do
    PubSub.subscribe(
      Durandal.PubSub,
      topic
    )
  end

  @spec unsubscribe(String.t()) :: :ok
  def unsubscribe(topic) do
    PubSub.unsubscribe(
      Durandal.PubSub,
      topic
    )
  end
end
