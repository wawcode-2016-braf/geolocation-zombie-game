defmodule Zombie.Game do
  use Zombie.Web, :model

  schema "games" do
    field :zombie, :boolean, default: false
    field :score, :integer
    belongs_to :user, Zombie.User

    timestamps()
  end

  @required_fields ~w(zombie score user_id)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:zombie, :score])
    |> validate_required([:zombie, :score])
  end
end
