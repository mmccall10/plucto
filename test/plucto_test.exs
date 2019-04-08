defmodule PluctoTest do
  use ExUnit.Case, async: false
  use Plug.Test
  doctest Plucto
  import Ecto.Query

  alias Plucto.Repo
  alias Plucto.Pet
  alias Plucto.Page

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
    assert %Page{current_page: 1} = Plucto.flip(query, conn, Repo)
  end

  test "default offset is 0" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{offset: 0} = Plucto.flip(query, conn, Repo)
  end

  test "default limit is 25" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{limit: 25} = Plucto.flip(query, conn, Repo)
  end

  test "total is calculated" do
    conn = conn(:get, "/pets")
    query = from(p in Pet)
    assert %Page{total: 50} = Plucto.flip(query, conn, Repo)
  end

  test "paginates" do
    conn = conn(:get, "/pets?page=2")
    query = from(p in Pet)
    assert %Page{current_page: 2, offset: 25} = Plucto.flip(query, conn, Repo)
  end

  test "from and to are set" do
    conn = conn(:get, "/pets?page=2")
    query = from(p in Pet)
    assert %Page{from: 26, to: 50} = Plucto.flip(query, conn, Repo)
  end

  test "return data list" do
    conn = conn(:get, "/pets?limit=5")
    query = from(p in Pet)
    assert %Page{data: [%Pet{} | _]} = Plucto.flip(query, conn, Repo)
  end

  test "sets last page" do
    conn = conn(:get, "/pets?limit=7")
    query = from(p in Pet)
    assert %Page{last_page: 8} = Plucto.flip(query, conn, Repo)
  end

  test "page and limit" do
    conn = conn(:get, "/pets?limit=5&page=3")
    query = from(p in Pet)

    assert %Page{current_page: 3, offset: 10, limit: 5, last_page: 10} =
             Plucto.flip(query, conn, Repo)
  end

  test "context/2 returns plucto page" do
    conn = conn(:get, "/pets?limit=5&page=2")
    query = from(p in Pet)

    assert %Page{limit: 5, offset: 5, current_page: 2, params: %{"limit" => "5", "page" => "2"}} =
             Plucto.context(conn)
  end

  test "flip/2 with %Plucto.Page{} from context/2 returns %Plucto.Page{} with results" do
    conn = conn(:get, "/pets?limit=6&page=2")
    query = from(p in Pet)
    results = conn |> Plucto.context() |> Plucto.flip(query, Repo)

    assert %Page{
             current_page: 2,
             from: 7,
             last_page: 9,
             limit: 6,
             offset: 6,
             params: %{"limit" => "6", "page" => "2"},
             path_info: ["pets"],
             query: %Ecto.Query{},
             repo: Plucto.Repo,
             to: 12,
             total: 50
           } = results
  end

  test "no repo raises Plucto.MissingRepoException" do
    conn = conn(:get, "/pets?limit=5&page=3")
    query = from(p in Pet)

    assert_raise Plucto.MissingRepoException, fn ->
      Plucto.flip(query, conn)
    end
  end

  test "check application config for repo" do
    Application.put_env(:plucto, :repo, Plucto.Repo)

    conn = conn(:get, "/pets?limit=5&page=3")
    query = from(p in Pet)
    page = conn |> Plucto.context() |> Plucto.flip(query)

    # reset env
    Application.put_env(:plucto, :repo, nil)

    assert %Page{repo: Plucto.Repo} = page
  end
end
