use Mix.Config

config :scixir,
  minio_broadway_list_name: System.get_env("MINIO_REDIS_NOTIFICATION_KEY"),
  scissor_broadway_list_name: System.get_env("SCIXIR_SCISSOR_BROADWAY_LIST_NAME")

config :scixir, :redis,
  host: System.get_env("MINIO_REDIS_URL"),
  notification_key: System.get_env("MINIO_REDIS_NOTIFICATION_KEY"),
  worker: System.get_env("MINIO_REDIS_LISTENER_WORKER")

config :ex_aws,
  access_key_id: System.get_env("MINIO_ACCESS_KEY"),
  secret_access_key: System.get_env("MINIO_SECRET_KEY")

config :ex_aws, :s3,
  scheme: "http://",
  host: System.get_env("MINIO_HOST"),
  port: System.get_env("MINIO_PORT")
