defmodule Zombie.LocationTest do
  use Zombie.ModelCase

  alias Zombie.Location

  @valid_attrs %{lat: "120.5", lon: "120.5", user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Location.changeset(%Location{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Location.changeset(%Location{}, @invalid_attrs)
    refute changeset.valid?
  end
end
