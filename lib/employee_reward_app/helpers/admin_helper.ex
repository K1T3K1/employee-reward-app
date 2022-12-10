defmodule EmployeeRewardApp.AdminHelper do

  import Ecto.Query

  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.User
  alias EmployeeRewardApp.AddPoint

  def get_user_list(current_user) do
    query =
      from(u in User,
        where: u.id != ^current_user,
        select: %{id: u.id, name: u.name, surname: u.surname, department: u.department}
      )

    Repo.all(query)
  end

  def get_recent_points_history() do
    query =
      from(log in AddPoint,
        order_by: [desc: log.inserted_at],
        limit: 300,
        preload: [:giving_user, :receiving_user]
      )

    Repo.all(query)
  end

  def update_user_reward_pool_limit(user_id, points_limit) do
    Repo.get_by(User, id: user_id) |> User.points_limit_changeset(%{points_limit: points_limit})
    |> Repo.update()
  end

  def generate_report(year, month) do
    query_for_sum = from(a in AddPoint,
              where: a.year == ^year and a.month == ^month,
              select: fragment("sum(?)", a.points_given))

    query_for_logs = from(a in AddPoint,
                    where: a.year == ^year and a.month == ^month,
                    order_by: [desc: a.inserted_at],
                    preload: [:giving_user, :receiving_user])
    {Repo.all(query_for_logs), Enum.at(Repo.all(query_for_sum), 0)}
  end

  def generate_report(year) do
    query_for_sum = from(a in AddPoint,
              where: a.year == ^year,
              select: fragment("sum(?)", a.points_given))

    query_for_logs = from(a in AddPoint,
                    where: a.year == ^year,
                    order_by: [desc: a.inserted_at],
                    preload: [:giving_user, :receiving_user])
    {Repo.all(query_for_logs), Enum.at(Repo.all(query_for_sum), 0)}
  end
end
