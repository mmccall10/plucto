defmodule Plucto.Repo.Migrations.CreatePetsTable do
  use Ecto.Migration

  def change do
    create table("pets") do
      add(:name, :string)
    end
  end
end
