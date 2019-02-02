defmodule Rolodex.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field(:name, :string)
  end

  def changeset(pet, params \\ %{}) do
    pet
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
