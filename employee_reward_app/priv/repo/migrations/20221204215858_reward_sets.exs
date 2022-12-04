defmodule EmployeeRewardApp.Repo.Migrations.RewardSets do
  use Ecto.Migration

  def change do
    create table(:reward_sets) do
      add(:reward_id, references(:rewards))

      timestamps()
    end
  end
end
