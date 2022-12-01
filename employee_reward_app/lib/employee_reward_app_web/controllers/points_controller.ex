defmodule EmployeeRewardAppWeb.PointsController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.AddPoints
  alias EmployeeRewardApp.PointsLog
  alias EmployeeRewardApp.User

  def new(conn, _param) do
    user = Guardian.Plug.current_resource(conn)
    month = Calendar.strftime(DateTime.utc_now, "%B")
    changeset = AddPoints.changeset(%AddPoints{}, %{})
    users = Repo.all(User) |> Enum.group_by(fn result -> result.id end, fn result -> %{name: result.name, surname: result.surname} end)
    render(conn, "new.html", [user: user, month: month, changeset: changeset, users: users])
  end

  def create(conn, %{"points_given" => points_given, "email" => email}) do
    user_id = Repo.get_by(User, email: email)
    current_user_id = conn.assings.current_user.id
    map_to_insert = %{points_given: points_given, receiving_userd_id: user_id, giving_user_id: current_user_id}
    changeset = %AddPoints{} |> AddPoints.changeset(map_to_insert)
    case Repo.insert(AddPoints, changeset) do
      {:ok, added_points} ->
        {year, month} = {DateTime.utc_now.year, DateTime.utc_now.month}
      end


  end

end
