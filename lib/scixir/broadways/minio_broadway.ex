defmodule Scixir.MinioBroadway do
  require Logger

  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    {list_name, working_list_name} = Scixir.Config.list_name(:minio)

    Scixir.Util.repush_working_messages(list_name, working_list_name)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {
          OffBroadway.Redis.Producer,
          redis_instance: :redix,
          list_name: list_name,
          working_list_name: working_list_name,
          receive_interval: 500
        },
        stages: 1
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
      "MinioBroadway: receive message with data #{inspect data}"
    end

    message
    |> Message.update_data(&generate_scissor_events/1)
  end

  defp generate_scissor_events(raw_data) do
    [_timestamp, [data]] = Jason.decode!(raw_data)

    case data do
      %{
        "s3" => %{
          "object" => %{
            "userMetadata" => %{
              "X-Amz-Meta-Scixir-Generated" => "true"
            }
          }
        }
      } = event ->
        Logger.debug fn ->
          "MinioBroadway: received scixir-generated event #{inspect event}"
        end
        []
      %{
        "s3" => %{
          "bucket" => %{
            "name" => bucket
          },
          "object" => %{
            "key" => key,
            "userMetadata" => %{
              "X-Amz-Meta-Versions" => versions,
              "X-Amz-Meta-Purpose" => purpose
            }
          }
        }
      } ->
        versions
        |> String.split("|", trim: true)
        |> Enum.map(fn version ->
          %Scixir.ScissorEvent{bucket: bucket, key: key, version: version, purpose: purpose}
        end)
      event ->
        Logger.warn fn ->
          "MinioBroadway: can not handle event #{inspect event}"
        end
        []
    end
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
      "MinioBroadway: RPUSH #{length events} events: #{inspect events}"
    end

    :ok
  end
end
