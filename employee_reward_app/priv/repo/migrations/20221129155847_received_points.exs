defmodule EmployeeRewardApp.Repo.Migrations.ReceivedPoints do
  use Ecto.Migration

  def change do
    create table(:received_points) do
      add(:points_received, references(:add_points, on_delete: :delete_all))
      add(:month, :string, primary_key: true)
      add(:year, :string, primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all), primary_key: true)

      timestamps()
    end
  end
end
