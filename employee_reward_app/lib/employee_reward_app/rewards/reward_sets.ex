defmodule EmployeeRewardApp.RewardSets do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:reward_id]
  schema "reward" do
    has_many(:reward, EmployeeRewardApp.Reward)

    timestamps()
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, @required)
    |> cast_assoc(:reward)
    |> validate_required(@required)
  end
end
