# KvUmbrella

## TODO

- [ ] Tests for distributed routing

## Running distributed version

In on shell:  
`KVS_PORT=4040 iex --sname foo -S mix`

In the other one:  
`KVS_PORT=4041 iex --sname bar -S mix`

The `foo` and `bar` node names correspond with the default routing configuration. The TCP listen ports
have to be different if running on the same machine.

## Running tests

Excluding distributed ones: `mix test`

With distributed, providing that the `bar` node is alive: `elixir --sname foo -S mix test`

With *only* distributed, providing that the bar node is alive: `elixir --sname foo -S mix test --only distributed`

## Configuration

### TCP Port

To configure the TCP port use the KVS_PORT environment variable

```shell
KVS_PORT=4040 iex --sname foo -S mix
```

If it's not provided the port will be taken from the `apps/kv_server/config/config.exs` file.

### Routing table

It is configured through the `config/configs.exs`:

```elixir
config :kv, routing_table: [{?a..?m, :"foo@szm-mac"},
                            {?n..?z, :"bar@szm-mac"}]
```

If the configuration is not provided the default one from the `apps/kv/config/config.exs` will be applied.
