# KvUmbrella

## Running tests

Excluding distributed ones: `mix test`

With distributed, providing that the `bar` node is alive: `elixir --sname foo -S mix test`

With *only* distributed, providing that the bar node is alive: `elixir --sname foo -S mix test --only distributed`

