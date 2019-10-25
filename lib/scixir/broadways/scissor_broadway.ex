defmodule Scixir.ScissorBroadway do
  require Logger

  use Broadway

  alias Broadway.Message
  alias Scixir.ScissorEvent

  @max_attempts 3

  def start_link(_opts) do
    {list_name, working_list_name} = Scixir.Config.list_name(:scissor)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module: {
            OffBroadway.Redis.Producer,
            redis_instance: :redix,
            list_name: list_name,
            working_list_name: working_list_name,
            receive_interval: 500
          },
          stages: 1
        ]
      ],
      processors: [
        default: [stages: 10]
      ]
    )
  end

  @impl true
  def handle_message(_, %Message{data: data} = message, _) do
    Logger.info fn ->
      "Scixir.ScissorBroadway: received message with data #{inspect data}"
    end

    process_event(data)

    message
  end

  defp process_event(raw_data) do
    raw_data
    |> Jason.decode!(keys: :atoms!)
    |> (fn data -> struct(ScissorEvent, data) end).()
    |> case do
      %{attempts: attempts} = event when attempts >= @max_attempts ->
        Logger.warn fn ->
          "Scixir.ScissorBroadway: reached the max_attempts, failed to process event: #{inspect event}"
        end

        :ok
      event ->
        process_scissor_event(event)
    end
  end

  defp process_scissor_event(%ScissorEvent{} = event) do
    case Scixir.Downloader.download(event) do
      {:ok, path} ->
        IO.inspect path
      :error ->
        prepend_scissor_event(event)

        Logger.warn fn ->
          "Scixir.ScissorBroadway: failed to process event #{inspect event}"
        end
    end
  end

  defp prepend_scissor_event(%ScissorEvent{attempts: attempts} = event) do
    {list_name, _} = Scixir.Config.list_name(:scissor)
    event = %{event | attempts: attempts + 1}
    str_event = Jason.encode!(event)

    {:ok, _} = Redix.command(:redix, ["LPUSH", list_name, str_event])

    Logger.info fn ->
      "Scixir.ScissorBroadway: LPUSH a retry scissor event: #{inspect event}"
    end

    :ok
  end
end
