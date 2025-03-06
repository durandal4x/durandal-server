defmodule Durandal.Helper.StringHelper do
  @moduledoc """
  A set of functions for helping operate on strings
  """

  @doc """
  Converts a number into a string we can format the way we want.

    format_number(10_000.50)
    > "10,000.5"

  """
  def format_number(x), do: format_number(x, ",")

  def format_number(nil, _), do: nil
  def format_number(%Decimal{} = v, separator), do: v |> Decimal.to_string() |> format_number(separator)
  def format_number(v, _) when v < 1000, do: v

  def format_number(v, separator) when is_integer(v) do
    v
    |> Integer.to_string()
    |> format_number(separator)
  end

  def format_number(v, separator) when is_float(v) do
    v
    |> Float.to_string()
    |> format_number(separator)
  end

  def format_number(v, separator) do
    v
    |> String.replace(~r/[0-9](?=(?:[0-9]{3})+(?![0-9]))/, "\\0#{separator}")
  end
end
