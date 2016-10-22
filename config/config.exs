use Mix.Config

import_config "../apps/*/config/config.exs"

config :kv, routing_table: [{?a..?m, :"foo@szm-mac"},
                            {?n..?z, :"bar@szm-mac"}]
config :kv_server,
  port: System.get_env("KVS_PORT") |> Integer.parse |> elem(0)
