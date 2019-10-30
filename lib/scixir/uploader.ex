defmodule Scixir.Uploader do
  alias Scixir.ScissorEvent

  def upload(%ScissorEvent{bucket: bucket, key: key, version: version}, file_path) do
    dirname = Path.dirname(key)
    extname = Path.extname(key)
    basename = Path.basename(key, extname)

    versioned_key =
      Path.join([
        dirname,
        "#{basename}_#{version}#{extname}"
      ])

    file_path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(bucket, versioned_key, meta: [{"Scixir-Generated", "true"}])
    |> ExAws.request()
  end
end
