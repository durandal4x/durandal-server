defmodule Durandal.Helper.NumberHelper do
  @moduledoc false

  def normalize(v) when is_list(v), do: Enum.map(v, &normalize/1)
  def normalize(v) when is_integer(v), do: _normalize(v)
  def normalize(v), do: v

  defp _normalize(v) when v > 1_000_000_000_000_000,
    do: "#{Float.round(v / 1_000_000_000_000_000, 2)}Q"

  defp _normalize(v) when v > 1_000_000_000_000, do: "#{Float.round(v / 1_000_000_000_000, 2)}T"
  defp _normalize(v) when v > 1_000_000_000, do: "#{Float.round(v / 1_000_000_000, 2)}B"
  defp _normalize(v) when v > 1_000_000, do: "#{Float.round(v / 1_000_000, 2)}M"
  defp _normalize(v) when v > 1_000, do: "#{Float.round(v / 1_000, 2)}K"
  defp _normalize(v), do: v
end
