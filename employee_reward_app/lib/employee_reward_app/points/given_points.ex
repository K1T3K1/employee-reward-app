defmodule EmployeeRewardApp.GivenPoints do
  alias EmployeeRewardApp.GivenPoints

  alias EmployeeRewardApp.Repo

  use Ecto.Schema
  import Ecto.Changeset

  @required [:points_given, :user_id, :month, :year]
  schema "given_points" do
    field(:points_given, :integer)
    field(:month, :integer)
    field(:year, :integer)
    belongs_to(:user, EmployeeRewardApp.User)

    timestamps()
  end

  def changeset(points_to_give, attrs) do
    cast(points_to_give, attrs, @required)
    |> cast_assoc(:user)
    |> validate_required(@required)
  end
end
