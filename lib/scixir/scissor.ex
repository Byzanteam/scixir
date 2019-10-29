defmodule Scixir.Scissor do
  import Gmex

  alias Scixir.ScissorEvent

  def process(%ScissorEvent{version: version, purpose: purpose}, image_path: image_path, dest_path: dest_path) do
    {resize_option, rest_options} = Keyword.split(
      version_options(purpose, version),
      [:resize]
    )

    image_path
    |> open()
    |> resize(resize_option)
    |> options(rest_options)
    |> save(dest_path)
  end

  defp version_options(purpose, version) do
    Scixir.Config.versions()
    |> get_in([String.to_atom(purpose), String.to_atom(version)])
    |> Enum.into([], fn
      {key, %{} = option} -> {key, Keyword.new(option)}
      {key, value} -> {key, value}
    end)
  end
end
