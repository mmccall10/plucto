use Mix.Config
config :plucto, ecto_repos: [Plucto.Repo]

# Test Repo settings
config :plucto, Plucto.Repo,
  username: "postgres",
  password: "",
  database: "Plucto_test",
  hostname: "localhost",
  poolsize: 10,
  # Ensure async testing is possible:
  pool: Ecto.Adapters.SQL.Sandbox
