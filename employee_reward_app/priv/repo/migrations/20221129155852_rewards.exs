defmodule EmployeeRewardApp.Repo.Migrations.Rewards do
  use Ecto.Migration

  def change do
    create table(:rewards) do
      add(:reward, :string)

      timestamps()
    end
  end
end
