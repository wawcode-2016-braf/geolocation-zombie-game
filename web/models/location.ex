defmodule Zombie.Location do
  use Zombie.Web, :model

  schema "locations" do
    field :lon, :decimal, precision: 14, scale: 10
    field :lat, :decimal, precision: 14, scale: 10
    belongs_to :user, Zombie.User

    timestamps()
  end

  @required_fields ~w(lon lat user_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:lon, :lat, :user_id])
    |> validate_required([:lon, :lat, :user_id])
  end
end
