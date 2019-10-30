defmodule Scixir.Downloader do
  require Logger

  use Agent

  alias Scixir.ScissorEvent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def download(%ScissorEvent{version: version} = event) do
    key = key(event)

    Agent.get_and_update __MODULE__, fn
      %{^key => %{path: path}} = state ->
        {
          {:ok, path},
          update_in(state, [key, :versions], fn versions ->
            MapSet.put(versions, version)
          end)
        }
      state ->
        case do_download(event) do
          {:ok, path} ->
            new_state =
              Map.put(state, key, %{path: path, versions: MapSet.new([version])})
            {{:ok, path}, new_state}
          :error ->
            {{:error, :download_failed}, state}
        end
    end
  end

  def remove(%ScissorEvent{version: version} = event) do
    key = key(event)

    Agent.cast __MODULE__, fn
      %{^key => %{path: path, versions: versions}} = state ->
        new_versions = MapSet.delete(versions, version)

        case MapSet.size(new_versions) do
          0 ->
            File.rm_rf(path)
            Map.delete(state, key)
          _ ->
            update_in(state, [key, :versions], fn _ -> new_versions end)
        end
      state ->
        state
    end
  end

  defp key(%ScissorEvent{bucket: bucket, key: key}) do
    {bucket, key}
  end

  defp do_download(%ScissorEvent{bucket: bucket, key: key} = event) do
    Logger.info fn ->
      "started to download file #{inspect event}"
    end

    with(
      {:ok, dest_path} <- Briefly.create(),
      {:ok, :done} <- bucket |> ExAws.S3.download_file(key, dest_path) |> ExAws.request
    ) do
      Logger.info fn ->
        "finished download file #{inspect event}"
      end
      {:ok, dest_path}
    else
      {:too_many_attempts, tmp, attempts} ->
        Logger.debug fn ->
          "tried #{attempts} times to create a temporary file at #{tmp} but failed. What gives?"
        end
        :error

      {:no_tmp, _tmps} ->
        Logger.debug fn ->
          "could not create a tmp directory to store temporary files. Set the :briefly :directory application setting to a directory with write permission"
        end
       :error

      error ->
        Logger.debug fn ->
          "coundl not download file, reason: #{inspect error}"
        end
        :error
    end
  end
end
