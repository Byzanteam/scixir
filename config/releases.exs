import Config

config :scixir,
  redis_uri: System.fetch_env!("MINIO_REDIS_URL"),
  minio_broadway_list_name: System.fetch_env!("MINIO_REDIS_NOTIFICATION_KEY"),
  scissor_broadway_list_name: System.fetch_env!("SCIXIR_SCISSOR_BROADWAY_LIST_NAME")

config :ex_aws,
  access_key_id: System.fetch_env!("MINIO_ACCESS_KEY"),
  secret_access_key: System.fetch_env!("MINIO_SECRET_KEY")

config :ex_aws, :s3,
  scheme: System.fetch_env!("MINIO_SCHEME"),
  host: System.fetch_env!("MINIO_HOST"),
  port: System.fetch_env!("MINIO_PORT")

logger_level =
  case System.get_env("MIX_LOGGER_LEVEL") do
    nil -> :info
    "" -> :info
    level when is_binary(level) -> String.to_atom(level)
  end

config :logger, level: logger_level
