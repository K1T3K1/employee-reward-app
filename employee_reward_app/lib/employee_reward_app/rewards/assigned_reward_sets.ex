defmodule EmployeeRewardApp.AssignedRewardSets do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:reward_set_id, :user_id]
  schema "reward" do
    field(:reward, :string)
    belongs_to(:user, EmployeeRewardApp.User)
    has_one(:reward_set, EmployeeRewardApp.RewardSets)

    timestamps()
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, @required)
    |> cast_assoc(:user)
    |> cast_assoc(:reward_set)
    |> validate_required(@required)
  end
end
