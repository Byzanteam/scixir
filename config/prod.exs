import Config

config :logger,
  backends: [{LoggerFileBackend, :file}, :console]

config :logger, :file,
  path: "/var/log/scixir/process.log",
  format: "$time $metadata[$level] $message\n",
  level: logger_level
