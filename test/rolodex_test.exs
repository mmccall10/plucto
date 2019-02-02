defmodule RolodexTest do
  use ExUnit.Case
  use Plug.Test
  doctest Rolodex
  import Ecto.Query

  alias Rolodex.Repo
  alias Rolodex.Pet
  alias Rolodex.Page

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    for _ <- 1..50 do
      %Pet{}
      |> Pet.changeset(%{name: Faker.Cat.name()})
      |> Repo.insert!()
    end

    :ok
  end

  test "default page is 1" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{current_page: 1} = Rolodex.flip(query, conn, Repo)
  end

  test "default offset is 0" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{offset: 0} = Rolodex.flip(query, conn, Repo)
  end

  test "default limit is 25" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{limit: 25} = Rolodex.flip(query, conn, Repo)
  end

  test "total is calculated" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{total: 50} = Rolodex.flip(query, conn, Repo)
  end

  test "paginates" do
    conn = conn(:get, "/pets?page=2")
    query = from(p in Pet)
    assert %Page{current_page: 2, offset: 25} = Rolodex.flip(query, conn, Repo)
  end

  test "from and to are set" do
    conn = conn(:get, "/pets?page=2")
    query = from(p in Pet)
    assert %Page{from: 26, to: 50} = Rolodex.flip(query, conn, Repo)
  end

  test "return data list" do
    conn = conn(:get, "/pets?limit=5")
    query = from(p in Pet)
    assert %Page{data: [%Pet{} | _]} = Rolodex.flip(query, conn, Repo)
  end

  test "sets last page" do
    conn = conn(:get, "/pets?limit=7")
    query = from(p in Pet)
    assert %Page{last_page: 8} = Rolodex.flip(query, conn, Repo)
  end

  test "page and limit" do
    conn = conn(:get, "/pets?limit=5&page=3")
    query = from(p in Pet)

    assert %Page{current_page: 3, offset: 10, limit: 5, last_page: 10} =
             Rolodex.flip(query, conn, Repo)
  end
end
