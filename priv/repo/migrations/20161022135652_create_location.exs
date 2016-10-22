defmodule Zombie.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :lon, :decimal, precision: 7
      add :lat, :decimal, precision: 7
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:locations, [:user_id])

  end
end
