defmodule EmployeeRewardApp.Repo.Migrations.AssignedRewardSets do
  use Ecto.Migration

  def change do
    create table(:assigned_reward_sets) do
      add(:reward_set_id, references(:reward_sets))
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
