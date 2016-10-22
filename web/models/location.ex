defmodule Zombie.Location do
  use Zombie.Web, :model

  schema "locations" do
    field :lon, :decimal, precision: 7
    field :lat, :decimal, precision: 7
    belongs_to :user, Zombie.User

    timestamps()
  end

  @required_fields ~w(lon lat user_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:lon, :lat])
    |> validate_required([:lon, :lat])
  end
end
