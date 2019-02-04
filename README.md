[![CircleCI](https://circleci.com/gh/pyramind10/rolodex.svg?style=svg)](https://circleci.com/gh/pyramind10/rolodex)
# Rolodex

Rolodex is a light weight unobtrusive pagination helper for elixir/phoenix(plug) web applications.
Rolodex is a simple library for asbtracting common pagination functionality.
Rolodex is intended to work with Plug and Ecto. It requires a conn struct, ecto query, and an ecto repo.

You might be familiar with query calls such as this:
```elixir
  %User{} |> Repo.all()
```

To write this using rolodex you would do:
```elixir
  from(u in User) |> Rolodex.flip(conn, Repo)
```

Rolodex is currently a configuration free library. It gets all the informaion it needs using the `Plug.Conn` struct.
The only two query parameters that matter are `page` and `limit`. Neither are required to initiate a paginated response. Rolodex will default to page 1 and a limit of 25.

Consider a page that list users.
www.officeadmin.com/users is paginatable due to the Rolodex defaults.

www.officeadmin.com/users is the same as this www.officeadmin.com/users?page=1

To change pages or set limits change the query string parameters.
www.officeadmin.com/users?page=2&limit=25

Rolodex currently relies an a database column `id` for the count aggregate. Totals will not execute with column name other than id.
ie. `Repo.aggregate(query, :count, :id)`

The `flip/3` function will return a `%Rolodex.Page{}` struct.

```elixir
defmodule Rolodex.Page do
  defstruct params: %{},
            repo: nil,
            query: nil,
            path_info: [],
            total: nil,
            limit: 25,
            offset: nil,
            current_page: nil,
            last_page: nil,
            from: nil,
            to: nil,
            data: []
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rolodex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rolodex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rolodex](https://hexdocs.pm/rolodex).

