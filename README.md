# Durandal server
The backend server for Durandal4x; initially the interface will also be created by this though longer term the expectation is to have either a dedicated front-end desktop or web application.

Currently much of the project is copied from a template project I use so some of the guides might be slightly off.

## Local dev
[Using docker](documentation/guides/local_setup_docker.md) - [Manually](documentation/guides/local_setup_manually.md)

TODO:
- Need a way to easily get https://fontawesome.com/download to work
- Need to have the root user get created automatically




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