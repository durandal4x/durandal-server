# Durandal server
The backend server for Durandal4x; initially the interface will also be created by this though longer term the expectation is to have either a dedicated front-end desktop or web application.

Currently much of the project is copied from a template project I use so some of the guides might be slightly off.

## Local dev TODO
- Need a way to easily get https://fontawesome.com/download to work
- Need to have the root user get created automatically

## Local dev - Docker
Unfortunately I'm not very good with Docker so haven't been able to get the assets compile correctly.
```bash
git clone git@github.com:durandal4x/durandal-server.git
cd durandal-server

docker compose up --build
# Now visit http://localhost:4000
```

## Local dev - Manually
```bash
sudo su postgres
psql postgres postgres <<EOF
CREATE USER durandal_dev WITH PASSWORD 'postgres';
CREATE DATABASE durandal_dev;
GRANT ALL PRIVILEGES ON DATABASE durandal_dev to durandal_dev;
ALTER USER durandal_dev WITH SUPERUSER;

CREATE USER durandal_test WITH PASSWORD 'postgres';
CREATE DATABASE durandal_test;
GRANT ALL PRIVILEGES ON DATABASE durandal_test to durandal_test;
ALTER USER durandal_test WITH SUPERUSER;
EOF
exit

git clone git@github.com:durandal4x/durandal-server.git
cd durandal-server
mix deps.get && mix deps.compile

asdf install
mix sass.install
iex -S mix phx.server
```

### Creating your admin account
```elixir
Durandal.Account.create_user(%{
  name: "root",
  email: "root@localhost",
  password: "password",
  groups: ["admin"], 
  permissions: ["admin"]
})
```

Editing it if you change something later
```elixir
user = Durandal.Account.get_user_by_email("root@localhost")
Durandal.Account.update_user(user, %{
  groups: ["admin"],
  permissions: ["admin"]
})
```