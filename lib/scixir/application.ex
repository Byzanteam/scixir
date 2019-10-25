defmodule Scixir.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Redix, name: :redix},
      {Scixir.MinioBroadway, []},
      supervisor(Scixir.Server.Supervisor, [])
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

    receive do
      {:DOWN, _, _, _, _} ->
        :ok
    end
  end
end
