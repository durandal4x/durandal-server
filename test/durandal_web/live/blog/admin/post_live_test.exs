defmodule DurandalWeb.PostLiveTest do
  @moduledoc false
  use DurandalWeb.ConnCase

  import Phoenix.LiveViewTest
  import Durandal.BlogFixtures
  alias Durandal.Blog

  @create_attrs %{contents: "some contents", title: "some title"}
  @update_attrs %{contents: "some updated contents", title: "some updated title"}
  @invalid_attrs %{contents: nil, title: nil}

  defp create_post(_) do
    {post, tag, post_tag} = post_with_tag_fixture()
    %{post: post, tag: tag, post_tag: post_tag}
  end

  describe "Anon auth test" do
    setup [:create_post]

    test "anon", %{conn: conn, post: post} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/posts")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }

      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/posts/#{post}")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }
    end
  end

  describe "Basic auth test" do
    setup [:auth, :create_post]

    test "basic user", %{post: post, conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/posts")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }

      {:error, {:redirect, resp}} = live(conn, ~p"/admin/blog/posts/#{post}")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }

      {:ok, _show_live, html} = live(conn, ~p"/blog/show/#{post}")
      refute html =~ "Delete post"
    end
  end

  describe "Index" do
    setup [:admin_auth, :create_post]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/blog/posts")

      assert html =~ "New post"
      refute html =~ post.title

      # What if there were no posts?
      Blog.delete_post(post)
      {:ok, _index_live, html} = live(conn, ~p"/admin/blog/posts")

      assert html =~ "New post"
      refute html =~ post.title
    end

    test "creates new post", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/blog/posts")

      index_live |> element("#tag-#{tag.id}") |> render_click()

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#post-form", post: @create_attrs)
             |> render_submit()

      assert_redirect(index_live, ~p"/blog")

      {:ok, _index_live, html} = live(conn, ~p"/blog")
      assert html =~ @create_attrs.title
    end
  end

  describe "Edit" do
    setup [:admin_auth, :create_post]

    test "updates the post", %{conn: conn, post: post} do
      {:ok, show_live, html} = live(conn, ~p"/admin/blog/posts/#{post}")

      assert html =~ "Update post"
      assert html =~ "Edit post"

      assert show_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#post-form", post: @update_attrs)
             |> render_submit()

      assert_redirect(show_live, ~p"/admin/blog/posts/#{post}")

      {:ok, _show_live, html} = live(conn, ~p"/admin/blog/posts/#{post}")
      assert html =~ "some updated contents"
    end

    test "Delete", %{conn: conn, post: post} do
      {:ok, show_live, html} = live(conn, ~p"/blog/show/#{post}")

      assert html =~ "Delete post"

      show_live
      |> element("#delete-post-button")
      |> render_click()

      assert_redirect(show_live, ~p"/blog")

      assert Blog.get_post(post.id) == nil
    end
  end
end
