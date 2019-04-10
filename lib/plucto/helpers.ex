defmodule Plucto.Helpers do
  alias Plucto.Page

  def page_url(
        page_num,
        %Page{params: params},
        %Plug.Conn{host: host, scheme: scheme, request_path: req_path},
        opts \\ []
      ) do
    query = %{params | "page" => page_num} |> URI.encode_query()
    path = "#{req_path}?#{query}"

    case Keyword.get(opts, :host, false) do
      false -> path
      _ -> "#{scheme}://#{host}#{path}"
    end
  end

  def next(
        %Page{params: params} = page,
        %Plug.Conn{} = conn,
        opts \\ []
      ) do
    {page_num, _} = Integer.parse(params["page"])

    (page_num + 1)
    |> page_url(page, conn, opts)
  end

  def previous(
        %Page{params: params} = page,
        %Plug.Conn{} = conn,
        opts \\ []
      ) do
    {page_num, _} = Integer.parse(params["page"])

    (page_num - 1)
    |> page_url(page, conn, opts)
  end

  def last(
        %Page{last_page: last_page} = page,
        %Plug.Conn{} = conn,
        opts \\ []
      ) do
    page_url(last_page, page, conn, opts)
  end

  def first(
        %Page{} = page,
        %Plug.Conn{} = conn,
        opts \\ []
      ) do
    page_url(1, page, conn, opts)
  end

  def range(%Page{} = page, padding \\ 3) do
    first.._ = left_range(page, padding)
    _..last = right_range(page, padding)

    first..last
  end

  def left_range(%Page{current_page: current_page, last_page: last_page}, padding \\ 3) do
    if current_page <= 1 do
      1..1
    else
      offset_left = current_page - padding

      if offset_left < 1 do
        1..(current_page - 1)
      else
        if offset_left > last_page do
          (last_page - padding)..(last_page - 1)
        else
          offset_left..(current_page - 1)
        end
      end
    end
  end

  def right_range(%Page{last_page: last_page, current_page: current_page}, padding \\ 3) do
    if current_page >= last_page do
      last_page..last_page
    else
      offset_right = current_page + padding

      if offset_right >= last_page do
        (current_page + 1)..last_page
      else
        (current_page + 1)..offset_right
      end
    end
  end
end
