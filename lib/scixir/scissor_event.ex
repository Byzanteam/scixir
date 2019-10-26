defmodule Scixir.ScissorEvent do
  @derive Jason.Encoder
  @enforce_keys [:bucket, :key, :version]
  defstruct [:bucket, :key, :version, attempts: 0]

  @type t :: %__MODULE__{
    bucket: binary(),
    key: binary(),
    version: binary(),
    attempts: non_neg_integer()
  }

  def transform_message(%{} = message, _opts) do
    Broadway.Message.update_data(message, fn raw_data ->
      raw_data
      |> Jason.decode!(keys: :atoms!)
      |> normalize()
    end)
  end

  def normalize(%{key: key} = map) do
    %{struct(__MODULE__, map) | key: URI.decode(key)}
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%{key: key, bucket: bucket, version: version, attempts: attempts}, opts) do
      concat([
        "#ScissorEvent<",
        group(concat([to_string(key), "@", to_string(bucket), "#", to_string(version)])),
        " ",
        group(space("attempts:", to_doc(attempts, opts))),
        ">"
      ])
    end
  end
end
