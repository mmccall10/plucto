defmodule Plucto.MissingRepoException do
  defexception [:message]
  @impl true
  def exception(_value) do
    msg = "An Ecto.Repo was not provided to plucto."
    %Plucto.MissingRepoException{message: msg}
  end
end
