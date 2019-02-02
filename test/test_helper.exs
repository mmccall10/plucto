ExUnit.start()
{:ok, _pid} = Rolodex.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Rolodex.Repo, :manual)
