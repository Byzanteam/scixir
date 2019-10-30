defmodule Scixir.Config do
  @doc """
  Get list_name in redis

  `:minio` for MinioBroadway
  `:scissor` for ScissorBroadway
  """
  def list_name(:minio) do
    list_name =
      Application.get_env(
        :scixir,
        :minio_broadway_list_name
      ) ||
        raise """
        minio_broadway_list_name is not configured.

        example configuration:

        config :scixir,
          minio_broadway_list_name: "some_list"
        """

    {list_name, list_name <> "_processing"}
  end

  def list_name(:scissor) do
    list_name =
      Application.get_env(
        :scixir,
        :scissor_broadway_list_name
      ) ||
        raise """
        scissor_broadway_list_name is not configured.

        example configuration:

        config :scixir,
          scissor_broadway_list_name: "some_list"
        """

    {list_name, list_name <> "_processing"}
  end

  @doc false
  def scissor_processor_stages do
    cast_scissor_processor_stages(Application.get_env(:scixir, :scissor_processor_stages))
  end

  defp cast_scissor_processor_stages(integer) when is_integer(integer), do: integer
  defp cast_scissor_processor_stages(str) when is_binary(str), do: String.to_integer(str)
  defp cast_scissor_processor_stages(nil), do: 10

  @doc """
  ```elixir
  %{
    project_cover_image: %{
      default: %{
        resize: %{
          width: 265,
          height: 165,
          type: :fill
        },
        gravity: "center",
        strip: true
      }
    },
    project_attachment: %{
      thumbnail: %{
        resize: %{
          width: 128,
          height: 96,
          type: :fill
        },
        gravity: "center",
        strip: true
      }
    }
  }
  ```
  """
  def versions do
    Application.fetch_env!(:scixir, :versions)
  end

  @doc false
  def normalize_versions_config do
    case Application.fetch_env!(:scixir, :versions) do
      versions when is_binary(versions) ->
        Application.put_env(
          :scixir,
          :versions,
          versions |> Base.decode64!() |> Jason.decode!(keys: :atoms) |> atomize_resize_type()
        )

      versions when is_map(versions) ->
        versions
    end
  end

  defp atomize_resize_type(config) do
    Enum.into(config, %{}, fn {purpose, purpose_options} ->
      {
        purpose,
        Enum.into(purpose_options, %{}, fn {version, version_options} ->
          case get_in(version_options, [:resize, :type]) do
            nil -> {version, version_options}
            type -> {version, put_in(version_options, [:resize, :type], String.to_atom(type))}
          end
        end)
      }
    end)
  end
end
