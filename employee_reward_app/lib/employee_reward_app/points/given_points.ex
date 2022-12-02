defmodule EmployeeRewardApp.GivenPoints do
  alias EmployeeRewardApp.GivenPoints

  alias EmployeeRewardApp.Repo

  use Ecto.Schema
  import Ecto.Changeset


  @required [:points_given, :user_id, :month, :year,]
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

  def add_new_points_changeset(struct, params) do
    {year, month} = {DateTime.utc_now.year, DateTime.utc_now.month}
    Repo.get_by!(GivenPoints, [user_id: params.user, month: to_string(month), year: to_string(year)])
    cast(struct, [params, month, year], @required)
    |> cast_assoc(:user)
    |> validate_required(@required)

  end
end
