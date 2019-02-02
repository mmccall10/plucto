defmodule Rolodex.MixProject do
  use Mix.Project

  def project do
    [
      app: :rolodex,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
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
      {:faker, "~> 0.11", only: :test}
    ]
  end

  defp aliases do
    [
      # Ensures database is reset before tests are run
      # test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
