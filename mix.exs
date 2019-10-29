defmodule Scixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :scixir,
      version: "0.2.0",
      elixir: "~> 1.9.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
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
      {:gmex, "~> 0.1.6"},
      {:redix, ">= 0.0.0"},
      {:jason, "~> 1.1"},
      {:briefly, "~> 0.4", github: "CargoSense/briefly"},

      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},

      {:broadway, "~> 0.5.0", github: "plataformatec/broadway", override: true},
      {:off_broadway_redis, "~> 0.4.0"}
    ]
  end

  defp releases do
    [
      scixir: [
        include_executables_for: [:unix]
      ]
    ]
  end
end
