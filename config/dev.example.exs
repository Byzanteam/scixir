import Config

config :scixir,
  redis_uri: System.get_env("SCIXIR_MINIO_REDIS_URL"),
  minio_broadway_list_name: System.get_env("SCIXIR_MINIO_BROADWAY_LIST_NAME"),
  scissor_broadway_list_name: System.get_env("SCIXIR_SCISSOR_BROADWAY_LIST_NAME")

config :ex_aws,
  access_key_id: System.get_env("SCIXIR_MINIO_ACCESS_KEY"),
  secret_access_key: System.get_env("SCIXIR_MINIO_SECRET_KEY")

config :ex_aws, :s3,
  scheme: System.fetch_env!("SCIXIR_MINIO_SCHEME"),
  host: System.get_env("SCIXIR_MINIO_HOST"),
  port: System.get_env("SCIXIR_MINIO_PORT")
