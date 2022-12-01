defmodule EmployeeRewardApp.GivenPoints do
  use Ecto.Schema
  import Ecto.Changeset

  schema "given_points" do
    field(:points_given, :integer)
    field(:month, :string)
    field(:year, :string)
    belongs_to(:user_id, EmployeeRewardApp.User)

    timestamps()
  end

  def changeset(points_to_give, attrs) do
    cast(points_to_give, attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
