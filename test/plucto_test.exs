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
    query = results = from(p in Pet) |> Plucto.flip(Plucto.context(conn), Repo)

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

    conn = conn(:get, "/pets?limit=5&page=5")
    page_context = Plucto.context(conn)
    page = from(p in Pet) |> Plucto.flip(page_context)

    # reset env
    Application.put_env(:plucto, :repo, nil)

    assert %Page{repo: Plucto.Repo} = page
  end

  test "range/2 returned full range" do
    conn = conn(:get, "/pets?page=50&limit=1")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.range(page, 5)

    assert 40..50 = range
  end

  test "range/2 returns full range from left pad start to right pad end" do
    conn = conn(:get, "/pets?page=1&limit=1")

    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.range(page)

    assert 1..6 = range
  end

  test "left_range/2 return proper range" do
    conn = conn(:get, "/pets?page=4&limit=5")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.left_range(page)

    assert 1..3 = range
  end

  test "right_range/2 return proper range" do
    conn = conn(:get, "/pets?page=4&limit=5")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.right_range(page)

    assert 5..7 = range
  end

  test "right_range/2 does not go beyond last page" do
    conn = conn(:get, "/pets?page=9&limit=5")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.right_range(page)

    assert 10..10 = range
  end

  test "left_range/2 does not go beyond first page" do
    conn = conn(:get, "/pets?page=2&limit=5")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.left_range(page)

    assert 1..1 = range
  end

  test "left_range/2 does not go beyond last page" do
    conn = conn(:get, "/pets?page=120&limit=5")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.left_range(page)

    assert 7..9 = range
  end

  test "right_range/2 does not go beyond first page" do
    conn = conn(:get, "/pets?page=2&limit=25")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.right_range(page)

    assert 2..2 = range
  end

  test "right_range/2 accepts padding" do
    conn = conn(:get, "/pets?page=5&limit=1")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.right_range(page, 10)

    assert 6..15 = range
  end

  test "left_range/2 accepts padding" do
    conn = conn(:get, "/pets?page=10&limit=1")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    range = Plucto.Helpers.left_range(page, 10)

    assert 1..9 = range
  end

  test "next/2 returns proper uri" do
    conn = conn(:get, "/pets?page=5&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    next_uri = Plucto.Helpers.next(page, conn)

    assert "/pets?limit=5&page=6&q=Black+Dog" = next_uri
  end

  test "previous/2 returns proper uri" do
    conn = conn(:get, "/pets?page=5&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    next_uri = Plucto.Helpers.previous(page, conn)

    assert "/pets?limit=5&page=4&q=Black+Dog" = next_uri
  end

  test "last/2 returns proper uri" do
    conn = conn(:get, "/pets?page=5&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.last(page, conn)

    assert "/pets?limit=5&page=10&q=Black+Dog" = last_uri
  end

  test "first/2 returns proper uri" do
    conn = conn(:get, "/pets?page=5&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.first(page, conn)

    assert "/pets?limit=5&page=1&q=Black+Dog" = last_uri
  end

  test "page_url/2 sets page to 1 if no page is set" do
    conn = conn(:get, "/pets?page=5&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.first(page, conn)

    assert "/pets?limit=5&page=1&q=Black+Dog" = last_uri
  end

  test "page_url/2 works without page url parameter" do
    conn = conn(:get, "/pets?q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.page_url(2, page, conn)

    assert "/pets?page=2&q=Black+Dog" = last_uri
  end

  test "next/2 works without page url parameter" do
    conn = conn(:get, "/pets?q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.next(page, conn)

    assert "/pets?page=2&q=Black+Dog" = last_uri
  end

  test "next/2 won't gen url beyond last page" do
    conn = conn(:get, "/pets?page=150&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.next(page, conn)

    assert "/pets?limit=5&page=10&q=Black+Dog" = last_uri
  end

  test "previous/2 won't gen url beyond page 1" do
    conn = conn(:get, "/pets?page=1&limit=5&q=Black Dog")
    query = from(p in Pet)
    page = Plucto.flip(query, conn, Repo)

    last_uri = Plucto.Helpers.previous(page, conn)

    assert "/pets?limit=5&page=1&q=Black+Dog" = last_uri
  end
end
