defmodule EmployeeRewardApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:name, :string)
      add(:surname, :string)
      add(:password, :string, virtual: true)
      add(:password_hash, :string)
      add(:department, :string)

      timestamps()
    end
    create(unique_index(:users, [:email]))
  end
end
