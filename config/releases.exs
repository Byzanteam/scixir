import Config

config :scixir,
  redis_uri: System.fetch_env!("SCIXIR_MINIO_REDIS_URL"),
  minio_broadway_list_name: System.fetch_env!("SCIXIR_MINIO_BROADWAY_LIST_NAME"),
  scissor_broadway_list_name: System.fetch_env!("SCIXIR_SCISSOR_BROADWAY_LIST_NAME"),
  versions: System.fetch_env!("SCIXIR_VERSIONS"),
  scissor_processor_stages: System.get_env("SCIXIR_SCISSOR_PROCESSOR_STAGES")

config :ex_aws,
  access_key_id: System.fetch_env!("SCIXIR_MINIO_ACCESS_KEY"),
  secret_access_key: System.fetch_env!("SCIXIR_MINIO_SECRET_KEY")

config :ex_aws, :s3,
  scheme: System.fetch_env!("SCIXIR_MINIO_SCHEME"),
  host: System.fetch_env!("SCIXIR_MINIO_HOST"),
  port: System.fetch_env!("SCIXIR_MINIO_PORT")

logger_level =
  case System.get_env("MIX_LOGGER_LEVEL") do
    nil -> :info
    "" -> :info
    level when is_binary(level) -> String.to_atom(level)
  end

config :logger, level: logger_level
