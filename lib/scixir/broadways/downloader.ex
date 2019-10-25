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
      %{^key => %{path: path, versions: versions}} = state ->
        versions = MapSet.put(versions, version)
        {path, update_in(state, [key, :versions], versions)}
      state ->
        case do_download(event) do
          {:ok, path} ->
            versions = MapSet.new([version])
            {{:ok, path}, Map.put(state, key, %{path: path, versions: versions})}
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
            update_in(state, [key, :versions], new_versions)
        end
      state ->
        state
    end
  end

  defp key(%ScissorEvent{bucket: bucket, key: key}) do
    {bucket, key}
  end

  defp do_download(%ScissorEvent{bucket: bucket, key: key}) do
    with(
      {:ok, dest_path} <- Briefly.create(),
      {:ok, :done} <- bucket |> ExAws.S3.download_file(object_path(key), dest_path) |> ExAws.request
    ) do
      {:ok, dest_path}
    else
      {:too_many_attempts, tmp, attempts} ->
        Logger.warn fn ->
          "tried #{attempts} times to create a temporary file at #{tmp} but failed. What gives?"
        end
        :error

      {:no_tmp, _tmps} ->
        Logger.warn fn ->
          "could not create a tmp directory to store temporary files. Set the :briefly :directory application setting to a directory with write permission"
        end
        :error

     error ->
       Logger.warn fn ->
         "coundl not download file, reason: #{inspect error}"
       end
      :error
    end
  end

  defp object_path(key) do
    key |> URI.decode()
  end
end
