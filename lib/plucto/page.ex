defmodule Plucto.Page do
  @moduledoc false

  defstruct params: %{},
            repo: nil,
            query: nil,
            path_info: [],
            total: 0,
            limit: 25,
            offset: 0,
            current_page: 1,
            last_page: nil,
            from: 0,
            to: 0,
            data: []
end
