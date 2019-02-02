defmodule Rolodex.Page do
  @moduledoc false

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
