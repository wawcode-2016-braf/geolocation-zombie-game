defmodule Zombie.User do
  use Zombie.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end
end
