defmodule Scixir.Config do
  @doc """
  Get list_name in redis

  `:minio` for MinioBroadway
  `:scissor` for ScissorBroadway
  """
  def list_name(:minio) do
    list_name = Application.get_env(
      :scixir,
      :minio_broadway_list_name
    ) || raise """
    minio_broadway_list_name is not configured.

    example configuration:

    config :scixir,
      minio_broadway_list_name: "some_list"
    """

    {list_name, list_name <> "_processing"}
  end
  def list_name(:scissor) do
    list_name = Application.get_env(
      :scixir,
      :scissor_broadway_list_name
    ) || raise """
    scissor_broadway_list_name is not configured.

    example configuration:

    config :scixir,
      scissor_broadway_list_name: "some_list"
    """

    {list_name, list_name <> "_processing"}
  end

  @doc false
  def scissor_processor_stages do
    String.to_integer(
      Application.get_env(:scixir, :scissor_processor_stages)
    ) || 10
  end

  @doc false
  def versions do
    Application.fetch_env!(:scixir, :versions)
  end

  @doc false
  def update_versions_config do
    case Application.fetch_env!(:scixir, :versions) do
      versions when is_binary(versions) ->
        Application.put_env(:scixir, :versions, Jason.decode!(versions))
      versions when is_map(versions) ->
        versions
    end
  end
end
