defmodule EmployeeRewardApp.AdminHelper do
  import Ecto.Query

  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.User
  def foo() do

  end

  def get_user_list(current_user) do
    query =
      from(u in User,
        where: u.id != ^current_user,
        select: %{id: u.id, name: u.name, surname: u.surname, department: u.department}
      )

    Repo.all(query)
  end
end
