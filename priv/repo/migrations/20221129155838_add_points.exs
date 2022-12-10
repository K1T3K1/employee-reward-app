defmodule EmployeeRewardApp.Repo.Migrations.AddPoints do
  use Ecto.Migration

  def change do
    create table(:add_points) do
      add(:points_given, :integer)
      add(:receiving_user_id, references(:users, on_delete: :delete_all))
      add(:giving_user_id, references(:users, on_delete: :delete_all))
      add(:month, :integer)
      add(:year, :integer)

      timestamps()
    end
  end
end
