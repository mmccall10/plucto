defmodule Rolodex.Page do
  @moduledoc false

  defstruct params: %{},
            port: nil,
            host: nil,
            repo: nil,
            query: nil,
            path_info: [],
            total: nil,
            limit: 10,
            offset: nil,
            current_page: nil,
            last_page: nil,
            first_page_url: nil,
            last_page_url: nil,
            next_page_url: nil,
            prev_page_url: nil,
            path: nil,
            from: nil,
            to: nil,
            data: []
end
