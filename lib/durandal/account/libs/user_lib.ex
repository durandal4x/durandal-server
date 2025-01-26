defmodule Durandal.Account.UserLib do
  @moduledoc """
  Library of user related functions.
  """
  use DurandalMacros, :library
  alias Durandal.Account.{User, UserQueries}

  @doc false
  @spec user_topic(Durandal.user_id() | User.t()) :: String.t()
  def user_topic(%User{id: user_id}), do: "Durandal.Account.User:#{user_id}"
  def user_topic(user_id), do: "Durandal.Account.User:#{user_id}"

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @spec list_users(Durandal.query_args()) :: [User.t()]
  def list_users(query_args) do
    UserQueries.user_query(query_args)
    |> Durandal.Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(Durandal.user_id()) :: User.t()
  @spec get_user!(Durandal.user_id(), Durandal.query_args()) :: User.t()
  def get_user!(user_id, query_args \\ []) do
    (query_args ++ [id: user_id])
    |> UserQueries.user_query()
    |> Durandal.Repo.one!()
  end

  @doc """
  Gets a single user. Can take additional arguments for the query.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

      iex> get_user(123, preload: [:extra_user_data])
      %User{}

  """
  @spec get_user(Durandal.user_id(), Durandal.query_args()) :: User.t() | nil
  def get_user(user_id, query_args \\ []) do
    UserQueries.user_query(query_args ++ [id: user_id])
    |> Durandal.Repo.one()
  end

  @doc """
  Gets a single user by their user_id. If no user is found, returns `nil`.

  Makes use of a Cache

  ## Examples

      iex> get_user_by_id(123)
      %User{}

      iex> get_user_by_id(456)
      nil
  """
  @spec get_user_by_id(Durandal.user_id()) :: User.t() | nil
  def get_user_by_id(user_id) do
    case Cachex.get(:user_by_user_id_cache, user_id) do
      {:ok, nil} ->
        user = do_get_user_by_id(user_id)
        Cachex.put(:user_by_user_id_cache, user_id, user)
        user

      {:ok, value} ->
        value
    end
  end

  @spec do_get_user_by_id(Durandal.user_id()) :: User.t() | nil
  defp do_get_user_by_id(user_id) do
    UserQueries.user_query(id: user_id, limit: 1)
    |> Durandal.Repo.one()
  end

  @doc """
  Gets a single user by their name. If no user is found, returns `nil`.

  ## Examples

      iex> get_user_by_name("noodle")
      %User{}

      iex> get_user_by_name("nobody")
      nil
  """
  @spec get_user_by_name(String.t()) :: User.t() | nil
  def get_user_by_name(name) do
    UserQueries.user_query(where: [name_lower: name], limit: 1)
    |> Durandal.Repo.one()
  end

  @doc """
  Gets a single user by their email. If no user is found, returns `nil`.

  ## Examples

      iex> get_user_by_email("noodle@durandal")
      %User{}

      iex> get_user_by_email("nobody@nowhere")
      nil

  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) do
    UserQueries.user_query(where: [email: email], limit: 1)
    |> Durandal.Repo.one()
  end

  @doc """
  Creates a user with no checks, use this for system users or automated processes; for user registration make use of `register_user/1`.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    User.changeset(%User{}, attrs, :full)
    |> Durandal.Repo.insert()
  end

  @doc """
  Creates a user specifically via the registration changeset, you should use this for user-registration and `create_user/1` for system accounts or automated processes.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs \\ %{}) do
    User.changeset(%User{}, attrs, :register)
    |> Durandal.Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    User.changeset(user, attrs, :full)
    |> Durandal.Repo.update()
    |> maybe_decache_user()
  end

  # Clears the cache for a user after a successful database option
  @spec maybe_decache_user(any()) :: any()
  defp maybe_decache_user({:ok, user}) do
    Durandal.invalidate_cache(:user_by_user_id_cache, user.id)
    {:ok, user}
  end

  defp maybe_decache_user(v), do: v

  @doc """
  Updates a user's password.

  ## Examples

      iex> update_password(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_password(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_password(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_password(%User{} = user, attrs) do
    User.changeset(user, attrs, :change_password)
    |> Durandal.Repo.update()
    |> maybe_decache_user()
  end

  @doc """
  Updates a user but only the fields users are allowed to alter themselves.

  ## Examples

      iex> update_limited_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_limited_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_limited_user(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_limited_user(%User{} = user, attrs) do
    User.changeset(user, attrs, :user_form)
    |> Durandal.Repo.update()
    |> maybe_decache_user()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user) do
    Durandal.Repo.delete(user)
    |> maybe_decache_user()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user(User.t(), map) :: Ecto.Changeset.t()
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs, :full)
  end

  @spec change_user_registration(User.t(), map) :: Ecto.Changeset.t()
  def change_user_registration(%User{} = _user, attrs \\ %{}) do
    User.changeset(%User{}, attrs, :register)
  end

  @doc """
  Takes a user, a plaintext password and returns a boolean if the password is
  correct for the user. Note it does this via a secure method to prevent timing
  attacks, never manually verify the password with standard string comparison.
  """
  @spec valid_password?(User.t(), String.t()) :: boolean
  def valid_password?(user, plaintext_password) do
    User.valid_password?(plaintext_password, user.password)
  end

  @spec register_failed_login(User.id(), String.t() | nil, String.t() | atom) :: :ok
  def register_failed_login(_, _, :rate_limit), do: :ok
  def register_failed_login(nil, _, _), do: :ok

  def register_failed_login(user_id, ip, reason) do
    Cachex.incr(:ts_login_count_ip, ip)
    Cachex.incr(:ts_login_count_user, user_id)

    :telemetry.execute(
      [:durandal, :user, :failed_login],
      %{reason: reason},
      %{user_id: user_id, ip: ip}
    )

    # TODO: Call out to the audit log system
    # Durandal.create_audit_log(user_id, ip, "failed-login", %{reason: reason})

    :ok
  end

  @doc """
  Given a userid and optionally an IP, check if we have hit the maximum number of
  login attempts for this user.
  """
  @spec allow_login_attempt?(User.id(), String.t() | nil) :: boolean
  def allow_login_attempt?(_userid, ip \\ nil) do
    cond do
      allow_ip_login_attempt?(ip) == false ->
        false

      # allow_user_login_attempt?(userid) == false ->
      #   false

      true ->
        true
    end
  end

  @spec allow_ip_login_attempt?(String.t()) :: boolean
  defp allow_ip_login_attempt?(nil), do: true

  defp allow_ip_login_attempt?(ip) do
    max_allowed_ip = 3
    # TODO: Call out to get the maximum number of IP attempts
    # max_allowed_ip = Durandal.get_server_setting_value("login.ip_rate_limit")

    current_ip_count = Cachex.fetch!(:login_count_ip, ip, fn -> 0 end)

    # As long as we're below the max it's okay
    current_ip_count <= max_allowed_ip
  end

  @doc """
  Generates a strong, though not very human readable, password.

  ## Examples

    iex> generate_password()
    "d52r8i5BhA6xBtmp7ElHI3Y/U/qztw2jUkgdeoZijWBEYzTf5DSBR5N87283WDiA"
  """
  @spec generate_password() :: String.t()
  def generate_password do
    :crypto.strong_rand_bytes(64) |> Base.encode64(padding: false) |> binary_part(0, 64)
  end

  @doc """
  Tests if a User or user_id has all of the required permissions.

  If the user doesn't exist you will get back a failure.

  ## Examples

    iex> allow?(123, "Permission")
    true

    iex> allow?(123, "NotPermission")
    false
  """
  @spec allow?(Durandal.user_id() | User.t(), [String.t()] | String.t()) :: boolean
  def allow?(user_or_user_id, permissions) when is_binary(user_or_user_id),
    do: allow?(get_user_by_id(user_or_user_id), permissions)

  def allow?(%User{} = user, permissions) do
    permissions
    |> List.wrap()
    |> Enum.map(fn p -> Enum.member?(user.permissions, p) end)
    |> Enum.all?()
  end

  def allow?(_not_a_user, _), do: false

  @doc """
  Tests is the user name is acceptable. Can be over-ridden using the config [fn_user_name_acceptor](config.html#fn_user_name_acceptor)
  """
  @name_parts1 ~w(serene energised humble auspicious decisive exemplary cheerful determined playful spry springy)
  @name_parts2 ~w(
      maroon cherry rose ruby
      amber carrot
      lemon beige
      mint lime cadmium
      aqua cerulean
      lavender indigo
      magenta amethyst
    )
  @name_parts3 ~w(hamster gerbil cat dog falcon eagle mole fox tiger panda elephant lion cow dove whale dolphin squid dragon snake platypus badger)

  @spec generate_guest_name() :: String.t()
  def generate_guest_name() do
    case :rand.uniform(3) do
      1 -> [@name_parts1, @name_parts2]
      2 -> [@name_parts1, @name_parts3]
      3 -> [@name_parts2, @name_parts3]
    end
    |> Enum.map_join(" ", fn l -> Enum.random(l) |> String.capitalize() end)
  end

  @spec deliver_user_confirmation_instructions(User.t(), function()) :: {:ok, map()}
  def deliver_user_confirmation_instructions(%User{} = _user, _confirmation_url_fun) do
    # TODO: Implement confirmation function
    {:ok, %{}}
    # if user.confirmed_at do
    #   {:error, :already_confirmed}
    # else
    #   {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
    #   Repo.insert!(user_token)
    #   UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    # end
  end
end
