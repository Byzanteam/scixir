defmodule Scixir.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Scixir.Downloader,
      %{
        id: Redix,
        start: {
          Redix,
          :start_link,
          [Application.fetch_env!(:scixir, :redis_uri), [name: :redix]]
        }
      },
      {Scixir.MinioBroadway, []},
      {Scixir.ScissorBroadway, []}
    ]

    Scixir.Config.normalize_versions_config()

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
