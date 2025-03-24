defmodule Durandal.Engine.Commands.CommandGeneralTest do
  use Durandal.DataCase, async: true
  alias Durandal.Player.CommandLib
  import DurandalWeb.CoreComponents, only: [translate_internal_name: 1]

  # This test ensures each command name has a relevant translation in each locale
  @tag :translations
  test "ensure translations exist" do
    locales = Application.get_env(:durandal, DurandalWeb.Gettext)[:locales]

    commands = CommandLib.command_lookup()

    locales
    |> Enum.each(fn locale ->
      commands
      |> Enum.map(fn {_, command} ->
        name = command.name()

        result =
          Gettext.with_locale(locale, fn ->
            translate_internal_name(name)
          end)

        assert result != name,
          message: "Command name #{name} is not translated into locale #{locale}"
      end)
    end)
  end
end
