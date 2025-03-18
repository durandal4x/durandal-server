defmodule Durandal.BlogTest do
  @moduledoc false
  use Durandal.DataCase
  alias Durandal.Blog

  describe "tags" do
    alias Durandal.Blog.Tag

    import Durandal.BlogFixtures

    @invalid_attrs %{colour: nil, icon: nil, name: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Blog.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Blog.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{colour: "#AA0000", icon: "some icon", name: "some name"}

      assert {:ok, %Tag{} = tag} = Blog.create_tag(valid_attrs)
      assert tag.colour == "#AA0000"
      assert tag.icon == "some icon"
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{colour: "#0000AA", icon: "some updated icon", name: "some updated name"}

      assert {:ok, %Tag{} = tag} = Blog.update_tag(tag, update_attrs)
      assert tag.colour == "#0000AA"
      assert tag.icon == "some updated icon"
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_tag(tag, @invalid_attrs)
      assert tag == Blog.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Blog.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Blog.change_tag(tag)
    end
  end

  describe "posts" do
    alias Durandal.Blog.Post

    import Durandal.{AccountFixtures, BlogFixtures}

    @invalid_attrs %{
      contents: nil,
      title: nil,
      view_count: nil,
      poster_id: nil
    }

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()

      valid_attrs = %{
        contents: "some contents",
        title: "some title",
        view_count: 42,
        poster_id: user.id
      }

      assert {:ok, %Post{} = post} = Blog.create_post(valid_attrs)
      assert post.contents == "some contents"
      assert post.title == "some title"
      assert post.view_count == 42
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      update_attrs = %{
        contents: "some updated contents",
        title: "some updated title",
        view_count: 43
      }

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs)
      assert post.contents == "some updated contents"
      assert post.title == "some updated title"
      assert post.view_count == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end

  describe "post_tags" do
    alias Durandal.Blog.PostTag

    import Durandal.BlogFixtures

    @invalid_attrs %{post_id: nil, tag_id: nil}

    test "list_post_tags/0 returns all post_tags" do
      post_tag = post_tag_fixture()
      assert Blog.list_post_tags() == [post_tag]
    end

    test "get_post_tag!/1 returns the post_tag with given id" do
      post_tag = post_tag_fixture()
      assert Blog.get_post_tag!(post_tag.post_id, post_tag.tag_id) == post_tag
    end

    test "create_post_tag/1 with valid data creates a post_tag" do
      post = post_fixture()
      tag = tag_fixture()
      valid_attrs = %{post_id: post.id, tag_id: tag.id}

      assert {:ok, %PostTag{} = _post_tag} = Blog.create_post_tag(valid_attrs)
    end

    test "create_post_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post_tag(@invalid_attrs)
    end

    test "update_post_tag/2 with valid data updates the post_tag" do
      post_tag = post_tag_fixture()
      update_attrs = %{}

      assert {:ok, %PostTag{} = _post_tag} = Blog.update_post_tag(post_tag, update_attrs)
    end

    test "update_post_tag/2 with invalid data returns error changeset" do
      post_tag = post_tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post_tag(post_tag, @invalid_attrs)
      assert post_tag == Blog.get_post_tag!(post_tag.post_id, post_tag.tag_id)
    end

    test "delete_post_tag/1 deletes the post_tag" do
      post_tag = post_tag_fixture()
      assert {:ok, %PostTag{}} = Blog.delete_post_tag(post_tag)

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_post_tag!(post_tag.post_id, post_tag.tag_id)
      end
    end

    test "change_post_tag/1 returns a post_tag changeset" do
      post_tag = post_tag_fixture()
      assert %Ecto.Changeset{} = Blog.change_post_tag(post_tag)
    end
  end

  describe "user_preferences" do
    alias Durandal.Blog.UserPreference

    import Durandal.{AccountFixtures, BlogFixtures}

    @invalid_attrs %{
      disabled_posters: nil,
      disabled_tags: nil,
      enabled_posters: nil,
      enabled_tags: nil,
      tag_mode: nil,
      user_id: nil
    }

    test "list_user_preferences/0 returns all user_preferences" do
      user_preference = user_preference_fixture()
      assert Blog.list_user_preferences() == [user_preference]
    end

    test "get_user_preference!/1 returns the user_preference with given id" do
      user_preference = user_preference_fixture()
      assert Blog.get_user_preference!(user_preference.user_id) == user_preference
    end

    test "create_user_preference/1 with valid data creates a user_preference" do
      user = user_fixture()

      valid_attrs = %{
        disabled_posters: [
          "a00fc119-d16a-408b-a669-c1e632a7dec8",
          "94b4b4c4-1a0d-4031-b1c6-eea6dd9a91bd"
        ],
        disabled_tags: [
          "4a61cac4-6946-4c2e-81eb-eb3691b59e9d",
          "bbd9fe2d-f019-4186-bb63-57e3caf1cfe4"
        ],
        enabled_posters: [
          "c8872aa8-ec19-4eac-83f8-183c860f6556",
          "5d9591ee-f55f-4252-af78-e9d154109f39"
        ],
        enabled_tags: [
          "c7a02e74-63f3-400b-9403-f22fc8ff983d",
          "3f5ef2cd-0091-4ddf-9fc1-60111dcc35f7"
        ],
        tag_mode: "some tag_mode",
        user_id: user.id
      }

      assert {:ok, %UserPreference{} = user_preference} =
               Blog.create_user_preference(valid_attrs)

      assert user_preference.disabled_posters == [
               "a00fc119-d16a-408b-a669-c1e632a7dec8",
               "94b4b4c4-1a0d-4031-b1c6-eea6dd9a91bd"
             ]

      assert user_preference.disabled_tags == [
               "4a61cac4-6946-4c2e-81eb-eb3691b59e9d",
               "bbd9fe2d-f019-4186-bb63-57e3caf1cfe4"
             ]

      assert user_preference.enabled_posters == [
               "c8872aa8-ec19-4eac-83f8-183c860f6556",
               "5d9591ee-f55f-4252-af78-e9d154109f39"
             ]

      assert user_preference.enabled_tags == [
               "c7a02e74-63f3-400b-9403-f22fc8ff983d",
               "3f5ef2cd-0091-4ddf-9fc1-60111dcc35f7"
             ]

      assert user_preference.tag_mode == "some tag_mode"
    end

    test "create_user_preference/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_user_preference(@invalid_attrs)
    end

    test "update_user_preference/2 with valid data updates the user_preference" do
      user_preference = user_preference_fixture()

      update_attrs = %{
        disabled_posters: ["d9e76d50-88ee-4d18-91df-c403796fe732"],
        disabled_tags: ["1fd70a27-fb9e-4d5d-a09b-3596de251f8c"],
        enabled_posters: ["d785865f-ffb8-4f4e-a958-9cf7a88e77fc"],
        enabled_tags: ["449fcf42-9259-4060-8e75-4cf019d9d35a"],
        tag_mode: "some updated tag_mode"
      }

      assert {:ok, %UserPreference{} = user_preference} =
               Blog.update_user_preference(user_preference, update_attrs)

      assert user_preference.disabled_posters == ["d9e76d50-88ee-4d18-91df-c403796fe732"]
      assert user_preference.disabled_tags == ["1fd70a27-fb9e-4d5d-a09b-3596de251f8c"]
      assert user_preference.enabled_posters == ["d785865f-ffb8-4f4e-a958-9cf7a88e77fc"]
      assert user_preference.enabled_tags == ["449fcf42-9259-4060-8e75-4cf019d9d35a"]
      assert user_preference.tag_mode == "some updated tag_mode"
    end

    test "update_user_preference/2 with invalid data returns error changeset" do
      user_preference = user_preference_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Blog.update_user_preference(user_preference, @invalid_attrs)

      assert user_preference == Blog.get_user_preference!(user_preference.user_id)
    end

    test "delete_user_preference/1 deletes the user_preference" do
      user_preference = user_preference_fixture()
      assert {:ok, %UserPreference{}} = Blog.delete_user_preference(user_preference)

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_user_preference!(user_preference.user_id)
      end
    end

    test "change_user_preference/1 returns a user_preference changeset" do
      user_preference = user_preference_fixture()
      assert %Ecto.Changeset{} = Blog.change_user_preference(user_preference)
    end
  end
end
