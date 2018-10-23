defmodule RolodexTest do
  use ExUnit.Case
  doctest Rolodex

  test "greets the world" do
    assert Rolodex.hello() == :world
  end
end
