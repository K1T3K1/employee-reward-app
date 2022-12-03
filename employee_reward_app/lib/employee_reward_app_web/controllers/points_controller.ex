defmodule EmployeeRewardAppWeb.PointsController do
  use EmployeeRewardAppWeb, :controller

  import Ecto.Query
  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.AddPoints
  alias EmployeeRewardApp.User
  alias EmployeeRewardApp.GivenPoints
  alias EmployeeRewardApp.ReceivedPoints
  @points_limit 500000

  plug(:scrub_params, "add_points" when action in [:create])

  def new(conn, _param) do
    user = Guardian.Plug.current_resource(conn)
    month_string = get_month_string()
    {year, month} = get_month_year_int()
    changeset = AddPoints.changeset(%AddPoints{}, %{})

    users = get_user_list(user)
    current_user_points = get_user_given_points(conn, user.id, year, month)

    render(conn, "new.html",
      user: user,
      current_points: current_user_points,
      points_limit: @points_limit,
      month: month_string,
      changeset: changeset,
      users: users
    )
  end

  defp get_user_list(current_user) do
    query =
      from(u in User,
        where: u.id != ^current_user.id,
        select: %{id: u.id, name: u.name, surname: u.surname, department: u.department}
      )

    Repo.all(query)
  end

  defp get_month_string() do
    Calendar.strftime(DateTime.utc_now(), "%B")
  end

  defp get_month_year_int() do
    {DateTime.utc_now().year, DateTime.utc_now().month}
  end

  def create(conn, %{"add_points" => points_params}) do
    source_user = conn.assigns.current_user.id
    {year, month} = get_month_year_int()
    %{"points_given" => points, "user_id" => target_user} = points_params

    if target_user == nil do
      put_flash(conn, :error, "Select co-worker to be rewarded")
      |> redirect(to: Routes.points_path(conn, :new))
    end

    if points == nil do
      put_flash(conn, :error, "Input amount of points to reward co-worker with")
      |> redirect(to: Routes.points_path(conn, :new))
    end

    validate_points(
      conn,
      source_user,
      String.to_integer(target_user),
      year,
      month,
      String.to_integer(points)
    )
  end

  defp validate_points(conn, source_user, target_user, year, month, points) do
    case Repo.get_by(GivenPoints, user_id: source_user, year: year, month: month) do
      %GivenPoints{points_given: allocated_points, user_id: _id, month: _month, year: _year}
      when allocated_points + points <= @points_limit ->
        update_user_given_points(
          conn,
          source_user,
          target_user,
          year,
          month,
          allocated_points + points,
          points
        )

      nil ->
        insert_new_given_points_record(0, source_user, year, month)

      _default ->
        put_flash(
          conn,
          :error,
          "Select a co-worker and make sure you're not trying to assign over your monthly limit"
        )
        |> redirect(to: Routes.points_path(conn, :new))
    end
  end

  defp get_user_given_points(conn, source_user, year, month) do
    case Repo.get_by(GivenPoints, user_id: source_user, year: year, month: month) do
      %GivenPoints{points_given: allocated_points} ->
        allocated_points

      nil ->
        insert_new_given_points_record(0, source_user, year, month)
        get_user_given_points(conn, source_user, year, month)
    end
  end

  defp insert_new_given_points_record(points, user, year, month) do
    %GivenPoints{}
    |> GivenPoints.changeset(%{
      points_given: points,
      user_id: user,
      year: year,
      month: month
    })
    |> Repo.insert()
  end

  defp update_user_given_points(
         conn,
         source_user,
         target_user,
         year,
         month,
         points_to_update,
         points_assigned
       ) do
    user_receiving = Repo.get_by(User, id: target_user)

    GivenPoints
    |> Repo.get_by(user_id: source_user, year: year, month: month)
    |> GivenPoints.changeset(%{points_given: points_to_update})
    |> Repo.update()

    log_transaction(points_assigned, source_user, target_user)
    receive_points(target_user, points_assigned, year, month)

    put_flash(
      conn,
      :info,
      Integer.to_string(points_assigned) <>
        " " <> "points assigned to: " <> user_receiving.name <> " " <> user_receiving.surname
    )
    |> redirect(to: Routes.points_path(conn, :new))
  end

  defp log_transaction(points, source_user, target_user) do
    %AddPoints{}
    |> AddPoints.changeset(%{
      points_given: points,
      receiving_user_id: target_user,
      giving_user_id: source_user
    })
    |> Repo.insert()
  end

  defp receive_points(target_user, points, year, month) do
    case get_user_received_points(target_user, year, month) do
      %ReceivedPoints{points_received: previous_points} ->
        update_received_points(previous_points + points, target_user, year, month)

      nil ->
        insert_new_received_points_record(target_user, points, year, month)
    end
  end

  defp get_user_received_points(target_user, year, month) do
    Repo.get_by(ReceivedPoints, user_id: target_user, year: year, month: month)
  end

  defp update_received_points(points_sum, user, year, month) do
    get_user_received_points(user, year, month)
    |> ReceivedPoints.changeset(%{points_received: points_sum})
    |> Repo.update()
  end

  defp insert_new_received_points_record(user, points, year, month) do
    %ReceivedPoints{}
    |> ReceivedPoints.changeset(%{
      user_id: user,
      points_received: points,
      year: year,
      month: month
    })
    |> Repo.insert()
  end
end
