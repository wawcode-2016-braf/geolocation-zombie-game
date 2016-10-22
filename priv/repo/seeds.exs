# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Zombie.Repo.insert!(%Zombie.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Zombie.User.changeset(%Zombie.User{}, %{name: "test", email: "testuser@example.com", password: "secret", password_confirmation: "secret"})
|> Zombie.Repo.insert!