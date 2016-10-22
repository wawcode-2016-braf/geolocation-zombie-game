defmodule Zombie.GameTest do
  use Zombie.ModelCase

  alias Zombie.Game

  @valid_attrs %{score: 42, zombie: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Game.changeset(%Game{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Game.changeset(%Game{}, @invalid_attrs)
    refute changeset.valid?
  end
end
