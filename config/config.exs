import Config

config :logger, :console, format: "$dateT$time $metadata[$level] $levelpad$message\n"

config :briefly,
  directory: [{:system, "TMPDIR"}, {:system, "TMP"}, {:system, "TEMP"}, "/tmp"],
  default_prefix: "scixir",
  default_extname: ""

import_config "#{Mix.env()}.exs"
