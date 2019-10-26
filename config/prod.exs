use Mix.Config

config :scixir,
  redis_uri: System.get_env("SCIXIR_REDIS_URI"),
  minio_broadway_list_name: System.get_env("SCIXIR_MINIO_BROADWAY_LIST_NAME")
  scissor_broadway_list_name: System.get_env("SCIXIR_SCISSOR_BROADWAY_LIST_NAME")

config :ex_aws,
  access_key_id: System.get_env("MINIO_ACCESS_KEY"),
  secret_access_key: System.get_env("MINIO_SECRET_KEY")

config :ex_aws, :s3,
  scheme: System.get_env("MINIO_SCHEME"),
  host: System.get_env("MINIO_HOST"),
  port: System.get_env("MINIO_PORT")

logger_level =
  case System.get_env("MIX_LOGGER_LEVEL") do
    nil -> :info
    "" -> :info
    level when is_binary(level) -> String.to_atom(level)
  end

# Do not print debug messages in production
config :logger, level: logger_level
config :logger,
  backends: [{LoggerFileBackend, :file}, :console]

config :logger, :file,
  path: "/var/log/scixir/process.log",
  format: "$time $metadata[$level] $message\n",
  level: logger_level
