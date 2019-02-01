use Mix.Config
config :rolodex, ecto_repos: [Rolodex.Repo]

# Test Repo settings
config :rolodex, Rolodex.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rolodex_test",
  hostname: "localhost",
  poolsize: 10,
  # Ensure async testing is possible:
  pool: Ecto.Adapters.SQL.Sandbox
