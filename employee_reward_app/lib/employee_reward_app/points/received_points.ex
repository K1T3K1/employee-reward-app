defmodule EmployeeRewardApp.ReceivedPoints do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:points_received, :user_id, :month, :year]
  schema "received_points" do
    field(:points_received, :integer)
    field(:month, :integer)
    field(:year, :integer)
    belongs_to(:user, EmployeeRewardApp.User)

    timestamps()
  end

  def changeset(points_to_receive, attrs) do
    cast(points_to_receive, attrs, @required)
    |> cast_assoc(:user)
    |> validate_required(@required)
  end
end
