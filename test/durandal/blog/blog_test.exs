defmodule Durandal.BlogTest do
  @moduledoc false
  alias Durandal.AccountFixtures
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

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs, :update)
      assert post.contents == "some updated contents"
      assert post.title == "some updated title"
      assert post.view_count == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs, :update)
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
          "06091a57-a8a3-4fd4-b908-47f3a26fd14d",
          "0011504a-b287-48e1-ab13-b557c87862a2"
        ],
        disabled_tags: [
          "d7aae596-191a-4459-aa47-f542ec3c9000",
          "7f8825c8-af54-461c-9795-22fd682d2be1"
        ],
        enabled_posters: [
          "3cfa3d52-7412-41e4-91ec-61aaedbf6830",
          "414d317a-08aa-4d6e-b593-66eff607e85b"
        ],
        enabled_tags: [
          "58f1fd23-23d1-430f-9087-1a422afe0bfa",
          "9a62e557-5d97-49cb-b07d-89d1473a83ae"
        ],
        tag_mode: "some tag_mode",
        user_id: user.id
      }

      assert {:ok, %UserPreference{} = user_preference} =
               Blog.create_user_preference(valid_attrs)

      assert user_preference.disabled_posters == [
               "06091a57-a8a3-4fd4-b908-47f3a26fd14d",
               "0011504a-b287-48e1-ab13-b557c87862a2"
             ]

      assert user_preference.disabled_tags == [
               "d7aae596-191a-4459-aa47-f542ec3c9000",
               "7f8825c8-af54-461c-9795-22fd682d2be1"
             ]

      assert user_preference.enabled_posters == [
               "3cfa3d52-7412-41e4-91ec-61aaedbf6830",
               "414d317a-08aa-4d6e-b593-66eff607e85b"
             ]

      assert user_preference.enabled_tags == [
               "58f1fd23-23d1-430f-9087-1a422afe0bfa",
               "9a62e557-5d97-49cb-b07d-89d1473a83ae"
             ]

      assert user_preference.tag_mode == "some tag_mode"
    end

    test "create_user_preference/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_user_preference(@invalid_attrs)
    end

    test "update_user_preference/2 with valid data updates the user_preference" do
      user_preference = user_preference_fixture()

      update_attrs = %{
        disabled_posters: ["75487c91-5d6b-4821-956a-7b25acbfcdf8"],
        disabled_tags: ["14e9a6ad-29ac-4801-aa5a-609ad38c35f3"],
        enabled_posters: ["c0d094d6-f4ce-4880-bf3f-f506a6527ccb"],
        enabled_tags: ["86e64b79-f76b-4e8b-9225-d0a1cdbc723e"],
        tag_mode: "some updated tag_mode"
      }

      assert {:ok, %UserPreference{} = user_preference} =
               Blog.update_user_preference(user_preference, update_attrs)

      assert user_preference.disabled_posters == ["75487c91-5d6b-4821-956a-7b25acbfcdf8"]
      assert user_preference.disabled_tags == ["14e9a6ad-29ac-4801-aa5a-609ad38c35f3"]
      assert user_preference.enabled_posters == ["c0d094d6-f4ce-4880-bf3f-f506a6527ccb"]
      assert user_preference.enabled_tags == ["86e64b79-f76b-4e8b-9225-d0a1cdbc723e"]
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

  describe "poll_responses" do
    alias Durandal.Blog.PollResponse

    import Durandal.BlogFixtures

    @invalid_attrs %{post_id: nil, tag_id: nil}

    test "list_poll_responses/0 returns all poll_responses" do
      poll_response = poll_response_fixture()
      assert Blog.list_poll_responses() == [poll_response]
    end

    test "get_poll_response/1 returns the poll_response with given id" do
      poll_response = poll_response_fixture()
      assert Blog.get_poll_response(poll_response.user_id, poll_response.post_id) == poll_response
    end

    test "create_poll_response/1 with valid data creates a poll_response" do
      post = post_fixture()
      user = AccountFixtures.user_fixture()
      valid_attrs = %{post_id: post.id, user_id: user.id, response: "A"}

      assert {:ok, %PollResponse{} = _poll_response} = Blog.create_poll_response(valid_attrs)
    end

    test "create_poll_response/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_poll_response(@invalid_attrs)
    end

    test "update_poll_response/2 with valid data updates the poll_response" do
      poll_response = poll_response_fixture()
      update_attrs = %{}

      assert {:ok, %PollResponse{} = _poll_response} =
               Blog.update_poll_response(poll_response, update_attrs)
    end

    test "update_poll_response/2 with invalid data returns error changeset" do
      poll_response = poll_response_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Blog.update_poll_response(poll_response, @invalid_attrs)

      assert poll_response == Blog.get_poll_response(poll_response.user_id, poll_response.post_id)
    end

    test "delete_poll_response/1 deletes the poll_response" do
      poll_response = poll_response_fixture()
      assert {:ok, %PollResponse{}} = Blog.delete_poll_response(poll_response)

      assert Blog.get_poll_response(poll_response.user_id, poll_response.post_id) == nil
    end

    test "change_poll_response/1 returns a poll_response changeset" do
      poll_response = poll_response_fixture()
      assert %Ecto.Changeset{} = Blog.change_poll_response(poll_response)
    end
  end

  describe "uploads" do
    alias Durandal.Blog.Upload

    import Durandal.{AccountFixtures, BlogFixtures}

    @invalid_attrs %{
      filename: nil,
      type: nil,
      file_size: nil
    }

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()
      assert Blog.list_uploads() == [upload]
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert Blog.get_upload!(upload.id) == upload
    end

    test "create_upload/1 with valid data creates a upload" do
      user = user_fixture()

      valid_attrs = %{
        filename: "some contents",
        type: "some title",
        file_size: 42,
        uploader_id: user.id
      }

      assert {:ok, %Upload{} = upload} = Blog.create_upload(valid_attrs)
      assert upload.filename == "some contents"
      assert upload.type == "some title"
      assert upload.file_size == 42
    end

    test "create_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_upload(@invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload" do
      upload = upload_fixture()
      user = user_fixture()

      update_attrs = %{
        filename: "some updated contents",
        type: "some updated title",
        file_size: 43,
        uploader_id: user.id
      }

      assert {:ok, %Upload{} = upload} = Blog.update_upload(upload, update_attrs)
      assert upload.filename == "some updated contents"
      assert upload.type == "some updated title"
      assert upload.file_size == 43
    end

    test "update_upload/2 with invalid data returns error changeset" do
      upload = upload_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_upload(upload, @invalid_attrs)
      assert upload == Blog.get_upload!(upload.id)
    end

    test "delete_upload/1 deletes the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{}} = Blog.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset" do
      upload = upload_fixture()
      assert %Ecto.Changeset{} = Blog.change_upload(upload)
    end
  end
end
