defmodule Durandal.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Durandal.Blog` context.
  """
  alias Durandal.{Blog, AccountFixtures}

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        colour: "#AA0000",
        icon: "some icon",
        name: "some name"
      })
      |> Blog.create_tag()

    tag
  end

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    user = AccountFixtures.user_fixture()

    {:ok, post} =
      attrs
      |> Enum.into(%{
        poster_id: user.id,
        contents: "some contents",
        title: "some title",
        view_count: 42
      })
      |> Blog.create_post()

    post
  end

  @doc """
  Generate a post.
  """
  def post_with_tag_fixture(attrs \\ %{}) do
    user = AccountFixtures.user_fixture()
    tag = tag_fixture()

    {:ok, post} =
      attrs
      |> Enum.into(%{
        poster_id: user.id,
        contents: "some contents",
        title: "some title",
        view_count: 42
      })
      |> Blog.create_post()

    post_tag = post_tag_fixture(post_id: post.id, tag_id: tag.id)

    {post, tag, post_tag}
  end

  @doc """
  Generate a post_tag.
  """
  def post_tag_fixture(attrs \\ %{}) do
    post = post_fixture()
    tag = tag_fixture()

    {:ok, post_tag} =
      attrs
      |> Enum.into(%{
        post_id: post.id,
        tag_id: tag.id
      })
      |> Blog.create_post_tag()

    post_tag
  end

  @doc """
  Generate a user_preference.
  """
  def user_preference_fixture(attrs \\ %{}) do
    user = AccountFixtures.user_fixture()

    {:ok, user_preference} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        disabled_posters: [
          "6ef7eab6-3f2e-4671-ba24-01ab33cf5104",
          "90bbfbe8-0ab7-47eb-aab3-b4ad9e5e3ee0"
        ],
        disabled_tags: [
          "0e98ac59-6b13-408d-8084-4f067518dbe3",
          "9a7d24f7-7bf3-4c07-ab5f-6176d5f260c2"
        ],
        enabled_posters: [
          "e9e57c88-3a82-42ba-80f6-88abf749a46c",
          "e8213d57-e419-4e67-80ff-14fa56a2b18c"
        ],
        enabled_tags: [
          "3742ec1e-2921-4951-9ee3-bad1a828e549",
          "16ad0497-bd88-4773-a788-2e08dc0df591"
        ],
        tag_mode: "some tag_mode"
      })
      |> Blog.create_user_preference()

    user_preference
  end
end
