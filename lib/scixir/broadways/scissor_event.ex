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
end
