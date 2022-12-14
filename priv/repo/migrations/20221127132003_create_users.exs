defmodule EmployeeRewardApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string, null: false)
      add(:name, :string)
      add(:surname, :string)
      add(:password, :string, virtual: true)
      add(:password_hash, :string)
      add(:department, :string)
      add(:is_admin, :integer)
      add(:points_limit, :integer, default: 50)

      timestamps()
    end
    create(unique_index(:users, [:email]))
  end
end
