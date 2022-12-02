defmodule EmployeeRewardApp.ReceivedPoints do
  use Ecto.Schema
  import Ecto.Changeset

  schema "received_points" do
    field(:received_points, :integer)
    field(:month, :integer)
    field(:year, :integer)
    belongs_to(:user_id, EmployeeRewardApp.User)

    timestamps()
  end

  def changeset(points_to_give, attrs) do
    cast(points_to_give, attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
