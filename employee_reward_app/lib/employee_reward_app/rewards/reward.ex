defmodule EmployeeRewardApp.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:reward]
  schema "reward" do
    field(:reward, :string)

    timestamps()
  end

  def changeset(struct, attrs) do
    cast(struct, attrs, @required)
    |> validate_required(@required)
  end
end
