defmodule Scixir.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Scixir.Downloader,
      {Redix, name: :redix},
      {Scixir.MinioBroadway, []},
      {Scixir.ScissorBroadway, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)

    receive do
      {:DOWN, _, _, _, _} ->
        :ok
    end
  end
end
