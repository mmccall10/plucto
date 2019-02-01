defmodule RolodexTest do
  use ExUnit.Case
  doctest Rolodex

  alias Myproject.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "greets the world" do
    assert Rolodex.hello() == :world
  end
end
