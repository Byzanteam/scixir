defmodule Scixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :scixir,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :redix],
      mod: {Scixir.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mogrify, "~> 0.7.0"},
      {:redix, ">= 0.0.0"},

      {:jason, "~> 1.1"},
      {:gen_stage, "~> 0.14"},
      {:arc, "0.10.0"},
      {:elixir_uuid, "~> 1.2"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:httpoison, "~> 1.4.0", override: true},
      {:sweet_xml, "~> 0.6.5"},
      {:flow, "~> 0.14.3"},

      {:broadway, "~> 0.4.0"},
      {:off_broadway_redis, "~> 0.4.0"},

      {:decorator, "~> 1.2"},
      {:distillery, "~> 2.0"},
      {:logger_file_backend, github: "onkel-dirtus/logger_file_backend", only: [:prod, :dev]}
    ]
  end
end
