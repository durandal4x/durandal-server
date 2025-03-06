# Durandal.Game.Universe:{id}
Messages for universes as a whole

### `:updated_universe`
```elixir
%{
  event: :updated_universe,
  universe: Universe.t(),
}
```

### `:deleted_universe`
```elixir
%{
  event: :deleted_universe,
  universe: Universe.t(),
}
```

### `:tick_started`
```elixir
%{
  event: :started_tick,
  universe_id: Universe.id(),
  server_pid: pid(),
  task_pid: pid()
}
```

### `:tick_completed`
```elixir
%{
  event: :tick_started,
  universe_id: Universe.id(),
  server_pid: pid()
}
```

