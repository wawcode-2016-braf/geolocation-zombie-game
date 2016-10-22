defmodule Zombie.Repo.Migrations.RemoveCoherence do
  use Ecto.Migration

  def change do
    alter table(:users) do

      # authenticatable
      remove :password_hash
      # recoverable
      remove :reset_password_token
      remove :reset_password_sent_at
      # lockable
      remove :failed_attempts
      remove :locked_at
      # trackable
      remove :sign_in_count
      remove :current_sign_in_at
      remove :last_sign_in_at
      remove :current_sign_in_ip
      remove :last_sign_in_ip
      # unlockable_with_token
      remove :unlock_token

    end

  end
end
