# Player messages
Messages related to the player and their server

### Setting changed - `:setting_changed`
Sent when a setting is changed.

```elixir
%{
  event: :setting_changed,
  user_id: User.id(),
  key: atom,
  value: any
}
```

