defmodule EmployeeRewardAppWeb.PointsController do
  use EmployeeRewardAppWeb, :controller

  import Ecto.Query
  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.AddPoints
  alias EmployeeRewardApp.User
  alias EmployeeRewardApp.GivenPoints
  @points_limit 50

  def new(conn, _param) do
    user = Guardian.Plug.current_resource(conn)
    month = Calendar.strftime(DateTime.utc_now, "%B")
    changeset = AddPoints.changeset(%AddPoints{}, %{})
    query = from u in User,
            where: u.id != ^user.id,
            select: %{id: u.id, name: u.name, surname: u.surname}
    users = Repo.all(query)
    render(conn, "new.html", [user: user, month: month, changeset: changeset, users: users])
  end

  #def create(conn, %{"points_given" => points_given, "user_id" => user_id}) do
  #  current_user_id = conn.assigns.current_user.id
  #  |> IO.inspect()
  #  IO.puts(user_id)
  #  map_to_insert = %{points_given: points_given, receiving_user_id: user_id, giving_user_id: current_user_id}
  #  |> IO.inspect
  #  given_points_changeset = %GivenPoints{} |> GivenPoints.add_new_points_changeset(%{user: current_user_id, points_given: points_given})
  #  add_points_changeset = %AddPoints{} |> AddPoints.changeset(map_to_insert)
  #  case Repo.insert(add_points_changeset) do
  #    {:ok, added_points} ->
  #      {year, month} = {DateTime.utc_now.year, DateTime.utc_now.month}
  #    end
#
#
  #end
#
  def create(conn, %{"points_given" => points, "user_id" => target_user}) do
    source_user = conn.assigns.current_user.id
    {year, month} = {DateTime.utc_now.year, DateTime.utc_now.month}
    validate_points(conn, source_user, String.to_integer(target_user), year, month, String.to_integer(points))
  end

  defp validate_points(conn, source_user, target_user, year, month, points) do
    current_user_state = Repo.get_by(GivenPoints, [user_id: source_user, year: year, month: month])
    case current_user_state do
      %GivenPoints{points_given: allocated_points, user_id: _id, month: _month, year: _year} when ((allocated_points + points) <= @points_limit) ->
        update_user_points(conn, source_user, target_user, year, month, (allocated_points + points))
      :nil ->
        %GivenPoints{}
        |> GivenPoints.changeset(%{points_given: points, user_id: source_user, year: year, month: month})
        |> Repo.insert()

    end

  end

  defp update_user_points(conn, source_user, target_user, year, month, points) do
    user_receiving = Repo.get_by(User, id: target_user)
    IO.puts(points)
    GivenPoints
    |> Repo.get_by([user_id: source_user, year: year, month: month])
    |> GivenPoints.changeset(%{points_given: points})
    |> Repo.update
    IO.puts("a jak tutaj?")
    put_flash(conn, :info, "done")
    |> redirect(to: Routes.points_path(conn, :new))
  end
end
