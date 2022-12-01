defmodule EmployeeRewardApp.Repo.Migrations.Rewards do
  use Ecto.Migration

  def change do
    create table(:reward_sets) do
      add(:points_required, :integer)
      add(:reward, :string)

      timestamps()
    end
  end
end
