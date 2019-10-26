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
          stages: 1,
          transformer: {Scixir.ScissorEvent, :transform_message, []}
        ]
      ],
      processors: [
        default: [
          stages: 10,
          min_demand: 0, # Make sure processor request one event once
          max_demand: 1
        ]
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

  @impl true
  def handle_failed(messages, _) do
    Enum.each(messages, fn %{data: event} ->
      prepend_scissor_event(event)
    end)

    messages
  end

  defp process_event(%{attempts: attempts} = event) when attempts >= @max_attempts do
    Logger.warn fn ->
      "Scixir.ScissorBroadway: reached the max_attempts, failed to process event: #{inspect event}"
    end
  end
  defp process_event(%ScissorEvent{} = event) do
    with(
      {:ok, path} <- Scixir.Downloader.download(event),
      {:ok, dest_path} <- Briefly.create(),
      %{path: ^dest_path} <- Scixir.Scissor.process(event, image_path: path, dest_path: dest_path),
      {:ok, _} <- Scixir.Uploader.upload(event, dest_path)
    ) do
      Scixir.Downloader.remove(event)
      File.rm_rf(dest_path)

      Logger.info(fn ->
        "Scixir.ScissorBroadway: process successfully: #{inspect event}"
      end)
    else
      {:error, :download_failed} ->
        prepend_scissor_event(event)

        Logger.warn fn ->
          "Scixir.ScissorBroadway: failed to download image: #{inspect event}"
        end
      error ->
        prepend_scissor_event(event)

        Logger.warn fn ->
          "Scixir.ScissorBroadway: failed to process image: #{inspect event}, reason: #{inspect error}"
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
