defmodule Scixir.MinioBroadway do
  use Broadway

  def start_link(_opts) do
    {list_name, working_list_name} = get_list_name()

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module: {
            OffBroadway.Redis.Producer,
            redis_instance: :redix,
            list_name: list_name,
            working_list_name: working_list_name
          },
          stages: 1
        ]
      ],
      processors: [
        default: [stages: 2]
      ]
    )
  end

  defp get_list_name do
    list_name = Application.get_env(
      :scixir,
      :minio_broadway_list_name
    ) || raise """
    minio_broadway_list_name is not configured.

    config :scixir,
    minio_broadway_list_name: "some_list"

    """

    {list_name, list_name <> "_processing"}
  end
end
