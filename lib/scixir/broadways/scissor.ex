defmodule Scixir.Scissor do
  import Mogrify

  alias Scixir.ScissorEvent

  def process(%ScissorEvent{version: version}, image_path: image_path, dest_path: dest_path) do
    image_path
    |> open()
    |> resize_to_fill(size(version))
    |> gravity("Center")
    |> save(path: dest_path)
  end

  defp size(version) do
    Map.get(Scixir.Config.versions(), version)
  end
end
