defmodule DurandalWeb.Blog.Blog.PreferenceLiveTest do
  @moduledoc false
  use DurandalWeb.ConnCase

  import Phoenix.LiveViewTest
  import Durandal.BlogFixtures
  alias Durandal.Blog

  describe "Preference" do
    setup [:auth]

    test "no existing user_preference", %{conn: conn, user: user} do
      tag1 = tag_fixture(name: "tag1")
      tag2 = tag_fixture(name: "tag2")
      tag3 = tag_fixture(name: "tag3")

      assert Blog.get_user_preference(user.id) == nil

      {:ok, index_live, _html} = live(conn, ~p"/blog/preferences")
      assert Blog.get_user_preference(user.id) == nil

      # We default to blocking tags
      html = index_live |> element("#unassigned-disable-#{tag1.id}") |> render_click()

      assert html =~ "disabled-reset-#{tag1.id}"
      refute html =~ "disabled-reset-#{tag2.id}"
      refute html =~ "disabled-reset-#{tag3.id}"

      user_preference = Blog.get_user_preference(user.id)
      assert user_preference != nil
      assert user_preference.tag_mode == "Block"
      assert user_preference.enabled_tags == []
      assert user_preference.disabled_tags == [tag1.id]

      # Change mode
      html =
        index_live |> element("#change-tag-mode-form") |> render_change(%{"tag-mode" => "Filter"})

      refute html =~ "disabled-reset-#{tag1.id}"
      refute html =~ "disabled-reset-#{tag2.id}"
      refute html =~ "disabled-reset-#{tag3.id}"

      assert html =~ "unassigned-enable-#{tag1.id}"
      assert html =~ "unassigned-enable-#{tag2.id}"
      assert html =~ "unassigned-enable-#{tag3.id}"

      refute html =~ "unassigned-disable-#{tag1.id}"
      refute html =~ "unassigned-disable-#{tag2.id}"
      refute html =~ "unassigned-disable-#{tag3.id}"

      user_preference = Blog.get_user_preference(user.id)
      assert user_preference.tag_mode == "Filter"
      assert user_preference.enabled_tags == []
      assert user_preference.disabled_tags == []

      # Enable two tags
      index_live |> element("#unassigned-enable-#{tag2.id}") |> render_click()

      html = index_live |> element("#unassigned-enable-#{tag1.id}") |> render_click()

      refute html =~ "disabled-reset-#{tag1.id}"
      refute html =~ "disabled-reset-#{tag2.id}"
      refute html =~ "disabled-reset-#{tag3.id}"

      refute html =~ "unassigned-enable-#{tag1.id}"
      refute html =~ "unassigned-enable-#{tag2.id}"
      assert html =~ "unassigned-enable-#{tag3.id}"

      assert html =~ "enabled-reset-#{tag1.id}"
      assert html =~ "enabled-reset-#{tag2.id}"
      refute html =~ "enabled-reset-#{tag3.id}"

      user_preference = Blog.get_user_preference(user.id)
      assert user_preference.tag_mode == "Filter"
      assert user_preference.enabled_tags == [tag1.id, tag2.id]
      assert user_preference.disabled_tags == []
    end

    test "with existing user_preference", %{conn: conn, user: user} do
      tag1 = tag_fixture(name: "tag1")
      tag2 = tag_fixture(name: "tag2")
      tag3 = tag_fixture(name: "tag3")

      Blog.create_user_preference(%{
        user_id: user.id,
        tag_mode: "Filter and block",
        enabled_tags: [tag1.id],
        disabled_tags: [tag2.id]
      })

      {:ok, index_live, html} = live(conn, ~p"/blog/preferences")

      assert html =~ "enabled-reset-#{tag1.id}"
      assert html =~ "disabled-reset-#{tag2.id}"
      refute html =~ "enabled-reset-#{tag3.id}"
      refute html =~ "disabled-reset-#{tag3.id}"

      # Enable tag3
      html = index_live |> element("#unassigned-enable-#{tag3.id}") |> render_click()

      refute html =~ "unassigned-enable-#{tag1.id}"
      refute html =~ "unassigned-enable-#{tag2.id}"
      refute html =~ "unassigned-enable-#{tag3.id}"

      refute html =~ "unassigned-disable-#{tag1.id}"
      refute html =~ "unassigned-disable-#{tag2.id}"
      refute html =~ "unassigned-disable-#{tag3.id}"

      assert html =~ "enabled-reset-#{tag1.id}"
      assert html =~ "disabled-reset-#{tag2.id}"
      assert html =~ "enabled-reset-#{tag3.id}"

      user_preference = Blog.get_user_preference(user.id)
      assert user_preference.tag_mode == "Filter and block"
      assert user_preference.enabled_tags == [tag3.id, tag1.id]
      assert user_preference.disabled_tags == [tag2.id]
    end
  end
end
