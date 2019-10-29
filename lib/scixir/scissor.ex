defmodule Scixir.Scissor do
  import Gmex

  alias Scixir.ScissorEvent

  def process(%ScissorEvent{version: version, purpose: purpose}, image_path: image_path, dest_path: dest_path) do
    {selected_option, rest_options} = Keyword.split(
      version_options(purpose, version),
      [:resize]
    )

    resize_options =
      case selected_option do
        [resize: resize_options] -> resize_options
        _ -> []
      end

    image_path
    |> open()
    |> resize_image(resize_options)
    |> options(rest_options)
    |> save(dest_path)
  end

  def resize_image(image, []), do: image
  def resize_image(image, options), do: resize(image, options)

  def version_options(purpose, version) do
    Scixir.Config.versions()
    |> get_in([String.to_atom(purpose), String.to_atom(version)])
    |> Enum.into([], fn
      {key, %{} = option} -> {key, Keyword.new(option)}
      {key, value} -> {key, value}
    end)
  end
end
