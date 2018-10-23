defmodule Rolodex do
  import Ecto.Query, only: [from: 2]
  alias Rolodex.Page
  alias Plug.Conn

  @moduledoc """
  Rolodex is a light wieght unobtrusive pagination helper for elixir/phoenix web applications.
  Rolodex does not "integrate" with existing schemas, it is simply library for asbtracting common pagination functions.
  Rolodex is intended to work with Plug and Ecto. It requires a conn struct, ecto query, and ecto repo.

  You might be familiar with generated context functions such as this:
    %User{} |> Repo.all()

    To write this using rolodex you would do:
    from(u in User) |> Rolodex.flip(conn, Repo)

  Why the conn struct? Rolodex at this time is a configuration free library. It gets all the informaion it needs using the url.
  The only two parameter that matter are page and limit. Neither are required to initial a paginated response. Rolodex will default to page 1 and a limit of 10.

  Consider a page that list users, we will use the url www.officeadmin.com/users
  www.officeadmin.com/users is a paginatable route due to the defaults.
  www.officeadmin.com/users is the same as this www.officeadmin.com/users?page=1

  """

  def flip(query, %Conn{} = conn, repo) do
    %Page{
      params: conn.params,
      path_info: conn.path_info,
      port: conn.port,
      host: conn.host,
      repo: repo
    }
    |> current_page()
    |> limit()
    |> offset()
    |> paged_query(query)
    |> data()
    |> total()
    |> make_path()
    |> get_from()
    |> get_to()
    |> last_page()
    |> first_page_url()
    |> last_page_url()
    |> next_page_url()
    |> prev_page_url()
  end

  defp total(%Page{query: query, repo: repo} = page) do
    %{page | total: repo.aggregate(query, :count, :id)}
  end

  defp data(%Page{query: query, repo: repo} = page) do
    %{page | data: repo.all(query)}
  end

  defp paged_query(%Page{limit: limit, offset: offset} = page, %Ecto.Query{} = query) do
    q = from(q in query, limit: ^limit, offset: ^offset)
    %{page | query: q}
  end

  defp get_from(%Page{total: total} = page) when total == 0, do: page

  defp get_from(%Page{offset: offset} = page), do: %{page | from: offset + 1}

  defp get_to(%Page{total: total} = page) when total == 0, do: page

  defp get_to(%Page{offset: offset, data: data} = page),
    do: %{page | to: offset + Enum.count(data)}

  defp make_path(%Page{port: port, host: host, path_info: path_info} = page) do
    host =
      case port do
        80 -> host
        443 -> host
        _ -> "#{host}:#{port}"
      end

    %{page | path: "#{host}/" <> Enum.join(path_info, "/")}
  end

  defp first_page_url(%Page{total: total, limit: limit} = page) when total <= limit, do: page

  defp first_page_url(%Page{} = page), do: %{page | first_page_url: page_url(page, 1)}

  defp last_page_url(%Page{total: total, last_page: last_page, limit: limit} = page)
       when total <= limit or is_nil(last_page),
       do: page

  defp last_page_url(%Page{last_page: last_page} = page),
    do: %{page | last_page_url: page_url(page, last_page)}

  defp next_page_url(
         %Page{current_page: current_page, last_page: last_page, total: total, limit: limit} =
           page
       )
       when total <= limit or current_page == last_page,
       do: page

  defp next_page_url(%Page{current_page: current_page} = page),
    do: %{page | next_page_url: page_url(page, current_page + 1)}

  defp prev_page_url(%Page{current_page: current_page, total: total, limit: limit} = page)
       when total <= limit or current_page == 1,
       do: page

  defp prev_page_url(%Page{current_page: current_page} = page) do
    %{page | prev_page_url: page_url(page, current_page - 1)}
  end

  defp page_url(%Page{path: path, params: params, limit: limit}, page_num) do
    params_map =
      case params["limit"] do
        nil -> %{"page" => page_num}
        _ -> %{"page" => page_num, "limit" => limit}
      end

    query_string =
      params
      |> Map.merge(params_map)
      |> URI.encode_query()

    "#{path}?" <> query_string
  end

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
