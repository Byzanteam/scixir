# Scixir

## 流程

1. 从外部源（Minio 会把事件推到 Redis 里）接收事件
2. 解析事件，向流水线派发事件
3. Stage 1: 从 OSS 下载图片
4. Stage 2: 在本地裁剪图片
5. Stage 3: 向 OSS 上传图片

其中 Stage 1/2/3 均有多个 workers（进程）

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `scixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:scixir, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/scixir](https://hexdocs.pm/scixir).


### Misc:

##### minio event example:
```elixir
[
  %{
    "Event" => [
      %{
        "awsRegion" => "",
          "eventName" => "s3:ObjectCreated:Put",
          "eventSource" => "minio:s3",
          "eventTime" => "2020-10-27T12:44:26.629Z",
          "eventVersion" => "2.0",
          "requestParameters" => %{
            "accessKey" => "minio",
            "region" => "",
            "sourceIPAddress" => "192.168.32.1"
          },
          "responseElements" => %{
            "content-length" => "0",
            "x-amz-request-id" => "1641DA0728E9BD8E",
            "x-minio-deployment-id" => "08611c56-0ccc-4212-9fee-49ed4d6f1104",
            "x-minio-origin-endpoint" => "http://192.168.32.3:9090"
          },
          "s3" => %{
            "bucket" => %{
              "arn" => "arn:aws:s3:::jet-public",
              "name" => "jet-public",
              "ownerIdentity" => %{"principalId" => "minio"}
            },
            "configurationId" => "Config",
            "object" => %{
              "contentType" => "image/jpeg",
              "eTag" => "2c61024cc3c8431f965729235767bbd5",
              "key" => "avatar-2.jpeg",
              "sequencer" => "1641DA072A4DD4E2",
              "size" => 2014,
              "userMetadata" => %{
                "X-Amz-Meta-Versions" => "medium|large",
                "X-Amz-Meta-Purpose" => "app_assets",
                "content-type" => "image/png"
              },
            },
            "s3SchemaVersion" => "1.0"
          },
          "source" => %{
            "host" => "192.168.32.1",
            "port" => "",
            "userAgent" => "MinIO (darwin; amd64) minio-go/v7.0.6 mc/2020-10-03T02:54:56Z"
          },
          "userIdentity" => %{"principalId" => "minio"}
      }
    ],
    "EventTime" => "2020-10-27T12:44:26.629Z"
  }
]
```
```elixir
# legacy data structure
[
  "2019-10-25T12:39:17Z",
  [
    %{
      "awsRegion" => "",
      "eventName" => "s3:ObjectCreated:Post",
      "eventSource" => "minio:s3",
      "eventTime" => "2019-10-25T12:39:17Z",
      "eventVersion" => "2.0",
      "requestParameters" => %{
        "accessKey" => "",
        "region" => "",
        "sourceIPAddress" => "172.22.0.1"
      },
      "responseElements" => %{
        "x-amz-request-id" => "15D0E42E34106F40",
        "x-minio-deployment-id" => "b791aee5-b66c-4977-b7a3-5e0e2b552b6a",
        "x-minio-origin-endpoint" => "http://172.22.0.2:9090"
      },
      "s3" => %{
        "bucket" => %{
          "arn" => "arn:aws:s3:::jet-dev",
          "name" => "jet-dev",
          "ownerIdentity" => %{"principalId" => ""}
        },
        "configurationId" => "Config",
        "object" => %{
          "contentType" => "image/png",
          "eTag" => "3d6fc6420a19f31f0c4d37326b500f02",
          "key" => "d4fb47fc-6f6b-414c-a7a8-78a72132a0eb%2Fproject_attachment%2F8cee2744-3ada-48d4-9a9b-0f0c38d4ffd6_xX6N3m4BQm9-qT7UkL8Hcw.png",
          "sequencer" => "15D0E42E371475D9",
          "size" => 379932,
          "userMetadata" => %{
            "X-Amz-Meta-Versions" => "medium|large",
            "content-type" => "image/png"
          },
          "versionId" => "1"
        },
        "s3SchemaVersion" => "1.0"
      },
      "source" => %{
        "host" => "",
        "port" => "",
        "userAgent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36"
      },
      "userIdentity" => %{"principalId" => ""}
    }
  ]
]
```
