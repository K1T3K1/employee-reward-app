defmodule EmployeeRewardApp.Repo.Migrations.GivenPoints do
  use Ecto.Migration

  def change do
    create table(:given_points) do
      add(:points_given, :integer)
      add(:month, :integer, primary_key: true)
      add(:year, :integer, primary_key: true)
      add(:user_id, references(:users, on_delete: :delete_all), primary_key: true)

      timestamps()
    end
  end
end
