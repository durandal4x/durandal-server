defmodule DurandalWeb.FormattingComponents do
  use Phoenix.Component
  # alias Phoenix.LiveView.JS
  use Gettext, backend: DurandalWeb.Gettext

  alias Durandal.Helper.{NumberHelper, StringHelper}

  @doc """
  <.vector_string value={"value"} />
  <.vector_string value={"value"} separator=", " normalize={true} />
  """
  attr :value, :list, required: true
  attr :separator, :string, default: ", "
  attr :normalize, :boolean, default: true

  def vector_string(assigns) do
    formatted_value =
      if assigns[:normalize] do
        assigns[:value]
        |> NumberHelper.normalize()
        |> Enum.join(assigns[:separator])
      else
        assigns[:value]
        |> Enum.map_join(assigns[:separator], &StringHelper.format_number/1)
      end

    assigns =
      assigns
      |> assign(:formatted_value, formatted_value)

    ~H"""
    <span class="" title={inspect(@value)}>
      [{@formatted_value}]
    </span>
    """
  end
end
