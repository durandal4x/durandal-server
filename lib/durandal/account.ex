defmodule Durandal.Account do
  @moduledoc """

  """
  alias Durandal.Account.{User, UserLib, UserQueries}

  @doc false
  @spec user_topic(Durandal.user_id() | User.t()) :: String.t()
  defdelegate user_topic(user_or_user_id), to: UserLib

  @doc false
  @spec user_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate user_query(args), to: UserQueries

  @doc section: :user
  @spec list_users(list) :: [User.t()]
  defdelegate list_users(args), to: UserLib

  @doc section: :user
  @spec get_user!(Durandal.user_id()) :: User.t()
  @spec get_user!(Durandal.user_id(), Durandal.query_args()) :: User.t()
  defdelegate get_user!(user_id, query_args \\ []), to: UserLib

  @doc section: :user
  @spec get_user(Durandal.user_id()) :: User.t() | nil
  @spec get_user(Durandal.user_id(), Durandal.query_args()) :: User.t() | nil
  defdelegate get_user(user_id, query_args \\ []), to: UserLib

  @doc section: :user
  @spec get_user_by_id(Durandal.user_id()) :: User.t() | nil
  defdelegate get_user_by_id(user_id), to: UserLib

  @doc section: :user
  @spec get_user_by_name(String.t()) :: User.t() | nil
  defdelegate get_user_by_name(name), to: UserLib

  @doc section: :user
  @spec get_user_by_email(String.t()) :: User.t() | nil
  defdelegate get_user_by_email(email), to: UserLib

  @doc section: :user
  @spec create_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user(attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec register_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate register_user(attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec update_user(User, map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user(user, attrs), to: UserLib

  @doc section: :user
  @spec update_password(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_password(user, attrs), to: UserLib

  @doc section: :user
  @spec update_limited_user(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_limited_user(user, attrs), to: UserLib

  @doc section: :user
  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user(user), to: UserLib

  @doc section: :user
  @spec change_user(User.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user(user, attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec change_user_registration(User.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user_registration(user, attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec valid_password?(User.t(), String.t()) :: boolean
  defdelegate valid_password?(user, plaintext_password), to: UserLib

  @doc section: :user
  @spec generate_password() :: String.t()
  defdelegate generate_password(), to: UserLib

  @doc section: :user
  @spec allow?(Durandal.user_id() | User.t(), [String.t()] | String.t()) :: boolean
  defdelegate allow?(user_or_user_id, permission_or_permissions), to: UserLib

  @doc section: :user
  @spec generate_guest_name() :: String.t()
  defdelegate generate_guest_name(), to: UserLib

  @doc section: :user
  @spec deliver_user_confirmation_instructions(User.t(), function()) :: {:ok, map()}
  defdelegate deliver_user_confirmation_instructions(user, confirmation_url_fun), to: UserLib

  # UserTokens
  alias Durandal.Account.{UserToken, UserTokenLib, UserTokenQueries}

  @doc false
  @spec user_token_query(Durandal.query_args()) :: Ecto.Query.t()
  defdelegate user_token_query(args), to: UserTokenQueries

  @doc section: :user_token
  @spec list_user_tokens(Durandal.query_args()) :: [UserToken.t()]
  defdelegate list_user_tokens(args), to: UserTokenLib

  @doc section: :user_token
  @spec get_user_token!(UserToken.id()) :: UserToken.t()
  @spec get_user_token!(UserToken.id(), Durandal.query_args()) :: UserToken.t()
  defdelegate get_user_token!(user_token_id, query_args \\ []), to: UserTokenLib

  @doc section: :user_token
  @spec get_user_token(UserToken.id()) :: UserToken.t() | nil
  @spec get_user_token(UserToken.id(), Durandal.query_args()) :: UserToken.t() | nil
  defdelegate get_user_token(user_token_id, query_args \\ []), to: UserTokenLib

  @spec get_user_token_by_identifier(UserToken.identifier_code()) :: UserToken.t() | nil
  defdelegate get_user_token_by_identifier(identifier_code), to: UserTokenLib

  @spec get_user_token_by_identifier_renewal(
          UserToken.identifier_code(),
          UserToken.renewal_code()
        ) :: UserToken.t() | nil
  defdelegate get_user_token_by_identifier_renewal(identifier_code, renewal_code),
    to: UserTokenLib

  @doc section: :user_token
  @spec create_user_token(map) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user_token(attrs), to: UserTokenLib

  @doc section: :user_token
  @spec create_user_token(Durandal.user_id(), String.t(), String.t(), String.t()) ::
          {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user_token(user_id, context, user_agent, ip), to: UserTokenLib

  @doc section: :user_token
  @spec update_user_token(UserToken, map) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user_token(user_token, attrs), to: UserTokenLib

  @doc section: :user_token
  @spec delete_user_token(UserToken.t()) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user_token(user_token), to: UserTokenLib

  @doc section: :user_token
  @spec change_user_token(UserToken.t()) :: Ecto.Changeset.t()
  @spec change_user_token(UserToken.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user_token(user_token, attrs \\ %{}), to: UserTokenLib

  @spec get_user_from_token_identifier(UserToken.identifier_code()) :: User.t() | nil
  def get_user_from_token_identifier(identifier_code) do
    token = get_user_token_by_identifier(identifier_code)
    token && get_user_by_id(token.user_id)
  end
end
