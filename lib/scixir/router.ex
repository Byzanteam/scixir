defmodule Scixir.Router do
  use Plug.Router

  plug(Healthchex.Probes.Liveness)
  plug(Healthchex.Probes.Readiness)

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "OK")
  end
end
