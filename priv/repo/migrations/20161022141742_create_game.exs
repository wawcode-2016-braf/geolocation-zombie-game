defmodule Zombie.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :zombie, :boolean, default: true, null: false
      add :score, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:games, [:user_id])

  end
end
