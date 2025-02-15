# Local dev manual

## Install services
You will need to install:
- [Elixir/Erlang installed](https://elixir-lang.org/install.html).
- [Postresql](https://www.postgresql.org/download).

I prefer using [asdf](https://github.com/asdf-vm/asdf) and have included a `.tool-versions` to enable you to simply `asdf install`.

## Clone repo and pull dependencies
```bash
git clone git@github.com:durandal4x/durandal-server.git
cd durandal
mix deps.get && mix deps.compile
```

## Postgres setup
If you want to change the username or password then you will need to update the relevant files in [config](/config).
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
```

## SASS
We use sass for our css generation and you'll need to run this to get it started.
```bash
mix sass.install
```

## Running it
Standard mode
```bash
mix phx.server
```

Interactive REPL mode
```bash
iex -S mix phx.server
```

If all goes to plan you should be able to access your site locally at [http://localhost:4000/](http://localhost:4000/).

# Stuff for 
### Libraries you need to get yourself
The site makes use of [FontAwesome](https://fontawesome.com/) so if you are using the site you'll need to download the free version and do the following.

Note: Ensure you download the Web version, not the desktop version.
```bash
fontawesome/css/all.css -> priv/static/css/fontawesome.css
fontawesome/webfonts -> priv/static/webfonts
```

## Creating your admin account
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

## Resetting your user password
When running locally it's likely you won't want to connect the server to an email account, as such password resets need to be done a little differently.

Run your server with `iex -S mix phx.server` and then once it has started up use the following code to update your password.

```elixir
user = Durandal.Account.get_user_by_email("root@localhost")
Durandal.Account.update_user(user, %{"password" => "your password here"})
```
