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
end
