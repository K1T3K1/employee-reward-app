defmodule EmployeeRewardApp.AddPoint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "add_points" do
    field(:points_given, :integer)
    belongs_to(:receiving_user, EmployeeRewardApp.User)
    belongs_to(:giving_user, EmployeeRewardApp.User)
    field(:month, :integer)
    field(:year, :integer)

    timestamps()
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, [:points_given, :receiving_user_id, :giving_user_id, :year, :month])
    |> cast_assoc(:receiving_user)
    |> cast_assoc(:giving_user)
    |> validate_required([:points_given, :receiving_user_id, :giving_user_id])
  end
end
