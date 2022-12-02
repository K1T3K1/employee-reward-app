defmodule EmployeeRewardApp.AddPoints do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @points_limit 50

  alias EmployeeRewardApp.ReceivedPoints

  schema "add_points" do
    field(:points_given, :integer)
    belongs_to(:receiving_user, EmployeeRewardApp.User)
    belongs_to(:giving_user, EmployeeRewardApp.User)

    timestamps()
  end

  def changeset(struct, attrs) do
    IO.inspect(attrs)
    cast(struct, attrs, [:points_given, :receiving_user_id, :giving_user_id])
    |> cast_assoc(:receiving_user)
    |> cast_assoc(:giving_user)
    |> validate_required([:points_given, :receiving_user_id, :giving_user_id])
    end

  #def insert_points_changeset(struct, params) do
  #  {year, month} = {DateTime.utc_now.year, DateTime.utc_now.month}
  #  query = from r in GivenPoints,
  #            where: r.month == type(^month, :integer) and r.year == type(^year, :integer)
  #                  and r.user_id == type(^params.current_user_id, :integer),
  #            select: r.points_given
  #  user_points = Repo.get(query)
  #  user_points = user_points + params.points_given
  #  case user_points do
  #    user_points when user_points <= @points_limit ->
  #      ReceivedPoints.update_user_points_changeset(%ReceivedPoints{}, [user_points, month, year, ])
  #      cast(struct, params, [:points_given, :receiving_user_id, :giving_user_id])
  #    _points_higher_than_limit ->
  #      {:error, :points_over_limit}
  #  end
  #end
end
