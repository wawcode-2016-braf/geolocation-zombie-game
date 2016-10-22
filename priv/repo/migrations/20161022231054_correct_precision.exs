defmodule Zombie.Repo.Migrations.CorrectPrecision do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      modify :lon, :decimal, precision: 14, scale: 10
      modify :lat, :decimal, precision: 14, scale: 10
    end

  end
end
