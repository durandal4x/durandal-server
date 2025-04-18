defmodule DurandalWeb.TagLiveTest do
  @moduledoc false
  use DurandalWeb.ConnCase

  import Phoenix.LiveViewTest
  import Durandal.BlogFixtures
  alias Durandal.Blog

  @create_attrs %{colour: "#AA0000", icon: "some icon", name: "some name"}
  @update_attrs %{colour: "#0000AA", icon: "some updated icon", name: "some updated name"}
  @invalid_attrs %{colour: nil, icon: nil, name: nil}

  defp create_tag(_) do
    tag = tag_fixture()
    %{tag: tag}
  end

  describe "Anon auth test" do
    setup [:create_tag]

    test "anon", %{conn: conn, tag: tag} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/tags")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }

      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/tags/#{tag}")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }
    end
  end

  describe "Basic auth test" do
    setup [:auth, :create_tag]

    test "basic user", %{tag: tag, conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/tags")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }

      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/tags/#{tag}")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }
    end
  end

  describe "Index" do
    setup [:admin_auth, :create_tag]

    test "lists all tags", %{conn: conn, tag: tag} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/blog/tags")

      assert html =~ "New tag"
      assert html =~ tag.colour

      # What if there were no tags?
      Blog.delete_tag(tag)
      {:ok, _index_live, html} = live(conn, ~p"/admin/blog/tags")

      assert html =~ "New tag"
      refute html =~ tag.colour
    end

    test "creates new tag", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/blog/tags")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tag-form", tag: @create_attrs)
             |> render_submit()

      assert_redirect(index_live, ~p"/admin/blog/tags")

      {:ok, _index_live, html} = live(conn, ~p"/admin/blog/tags")
      assert html =~ "#AA0000"
    end
  end

  describe "Edit" do
    setup [:admin_auth, :create_tag]

    test "displays tag", %{conn: conn, tag: tag} do
      {:ok, _edit_live, html} = live(conn, ~p"/admin/blog/tags/#{tag}")

      assert html =~ "Edit tag"
      assert html =~ tag.colour
    end

    test "updates tag modal", %{conn: conn, tag: tag} do
      {:ok, edit_live, _html} = live(conn, ~p"/admin/blog/tags/#{tag}")

      assert edit_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert edit_live
             |> form("#tag-form", tag: @update_attrs)
             |> render_submit()

      assert_redirect(edit_live, ~p"/admin/blog/tags")

      {:ok, _index_live, html} = live(conn, ~p"/admin/blog/tags")
      assert html =~ "#0000AA"
    end
  end
end
