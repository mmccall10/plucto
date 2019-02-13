ExUnit.start()
{:ok, _pid} = Plucto.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Plucto.Repo, :manual)
