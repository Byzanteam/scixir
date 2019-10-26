defmodule Scixir.MinioBroadway do
  require Logger

  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    {list_name, working_list_name} = Scixir.Config.list_name(:minio)

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
        default: [stages: 1]
      ],
      batchers: [
        default: [stages: 1, batch_size: 10],
      ]
    )
  end

  @impl true
  def handle_message(_, %Message{data: data} = message, _) do
    Logger.info fn ->
      "Scixir.MinioBroadway: receive message with data #{inspect data}"
    end

    message
    |> Message.update_data(&generate_scissor_events/1)
  end

  defp generate_scissor_events(raw_data) do
    [_timestamp, [data]] = Jason.decode!(raw_data)

    events =
      case data do
        %{
          "s3" => %{
            "object" => %{
              "userMetadata" => %{
                "X-Amz-Meta-Scixir-Generated" => "true"
              }
            }
          }
        } ->
          []
        %{
          "s3" => %{
            "bucket" => %{
              "name" => bucket
            },
            "object" => %{
              "key" => key,
              "userMetadata" => %{
                "X-Amz-Meta-Versions" => versions
              }
            }
          }
        } ->
          versions
          |> String.split("|", trim: true)
          |> Enum.map(fn version ->
            %Scixir.ScissorEvent{bucket: bucket, key: key, version: version}
          end)
        _ ->
          []
      end

    Logger.debug fn ->
      "Scixir.MinioBroadway: generate scissor events: #{inspect events}"
    end

    events
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    messages
    |> Enum.map(&Map.get(&1, :data))
    |> List.flatten()
    |> append_scissor_events()

    messages
  end

  defp append_scissor_events([]), do: :ok
  defp append_scissor_events(events) do
    {list_name, _} = Scixir.Config.list_name(:scissor)
    str_events = Enum.map(events, &Jason.encode!(&1))

    {:ok, _} = Redix.command(:redix, ["RPUSH", list_name | str_events])

    Logger.info fn ->
      "Scixir.MinioBroadway: RPUSH #{length events} events: #{inspect events}"
    end

    :ok
  end
end
