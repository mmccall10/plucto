defmodule Plucto do
  import Ecto.Query, only: [from: 2]
  alias Plucto.Page
  alias Plug.Conn

  @moduledoc """
  Plucto is a light wieght unobtrusive pagination helper for elixir/phoenix web applications.
  Plucto does not "integrate" with existing schemas, it is simply library for asbtracting common pagination functions.
  Plucto is intended to work with Plug and Ecto. It requires a conn struct, ecto query, and ecto repo.

  You might be familiar with generated context functions such as this:
    User |> Repo.all()

    To write this using Plucto you would do:
    from(u in User) |> Plucto.flip(conn, Repo)

  Why the conn struct? Plucto is a configuration free library. It gets all the informaion it needs using the url.
  The only two parameter that matter are page and limit. Neither are required to initial a paginated response. Plucto will default to page 1 and a limit of 25.

  Consider a page that list users, we will use the url www.officeadmin.com/users
  www.officeadmin.com/users is a paginatable route due to the defaults.
  www.officeadmin.com/users is the same as this www.officeadmin.com/users?page=1

  """

  def flip(query, page_or_conn, repo \\ nil)

  def flip(%Ecto.Query{} = query, %Page{} = page, repo) do
    page
    |> get_repo(repo)
    |> do_paginate(query)
  end

  def flip(%Ecto.Query{} = query, %Conn{} = conn, repo) do
    conn
    |> page_from_conn()
    |> get_repo(repo)
    |> do_paginate(query)
  end

  def context(%Conn{} = conn) do
    page_from_conn(conn)
  end

  defp page_from_conn(conn) do
    conn = Plug.Conn.fetch_query_params(conn)

    %Page{
      params: conn.params,
      path_info: conn.path_info
    }
    |> current_page()
    |> limit()
    |> offset()
  end

  defp get_repo(%Page{} = page, repo) do
    maybe_config_repo = repo || Application.get_env(:plucto, :repo)

    if is_nil(maybe_config_repo) do
      raise Plucto.MissingRepoException
    else
      %{page | repo: maybe_config_repo}
    end
  end

  defp do_paginate(%Page{} = page, query) do
    page
    |> paged_query(query)
    |> data()
    |> total(query)
    |> get_from()
    |> get_to()
    |> last_page()
  end

  defp total(%Page{repo: repo} = page, query) do
    %{page | total: repo.aggregate(query, :count, :id)}
  end

  defp data(%Page{query: query, repo: repo} = page) do
    %{page | data: repo.all(query)}
  end

  defp paged_query(%Page{limit: limit, offset: offset} = page, %Ecto.Query{} = query) do
    %{page | query: from(q in query, limit: ^limit, offset: ^offset)}
  end

  defp get_from(%Page{total: total} = page) when total == 0, do: page

  defp get_from(%Page{offset: offset} = page), do: %{page | from: offset + 1}

  defp get_to(%Page{total: total} = page) when total == 0, do: page

  defp get_to(%Page{offset: offset, data: data} = page),
    do: %{page | to: offset + Enum.count(data)}

  defp last_page(%Page{total: total, limit: limit} = page) when total < limit, do: page

  defp last_page(%Page{total: total, limit: limit} = page) do
    last_page = (total / limit) |> Float.ceil() |> round
    %{page | last_page: last_page}
  end

  defp offset(%Page{current_page: current_page, limit: limit} = page),
    do: %{page | offset: current_page * limit - limit}

  defp limit(%Page{params: params} = page) do
    case params["limit"] do
      nil ->
        page

      val ->
        case Integer.parse(val) do
          {limit, ""} -> %{page | limit: limit}
          _ -> %{page | limit: 1}
        end
    end
  end

  # get the page
  defp current_page(%Page{params: params} = page) do
    case params["page"] do
      nil ->
        %{page | current_page: 1}

      val ->
        case Integer.parse(val) do
          {current_page, ""} -> %{page | current_page: current_page}
          _ -> %{page | current_page: 1}
        end
    end
  end
end
