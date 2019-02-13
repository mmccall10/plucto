defmodule Plucto.MixProject do
  use Mix.Project

  def project do
    [
      app: :plucto,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      name: "Plucto",
      description: description(),
      source_url: "https://github.com/pyramind10/plucto",
      package: package()
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "0.14.1", only: :test},
      {:faker, "~> 0.11", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      # Ensures database is reset before tests are run
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp description() do
    "Plucto is a light weight pagination helper for phoenix/plug web applications using ecto."
  end

  defp package() do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/pyramind10/plucto"}
    ]
  end
end
