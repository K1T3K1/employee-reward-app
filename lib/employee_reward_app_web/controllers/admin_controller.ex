defmodule EmployeeRewardAppWeb.AdminController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.AdminHelper
  alias EmployeeRewardApp.PointsHelper
  alias EmployeeRewardApp.User

  def new(conn, _params) do
    current_user = conn.assigns.current_user.id
    points_limit_changeset = User.points_limit_changeset(%User{}, %{})
    user_list = AdminHelper.get_user_list(current_user)
    recent_points_log = AdminHelper.get_recent_points_history()

    render(conn, "new.html",
      points_limit_changeset: points_limit_changeset,
      users: user_list,
      recent_points_log: recent_points_log
    )
  end

  def update(conn, %{"user" => %{"reward_pool_limit" => reward_pool_limit, "user_id" => user_id}}) do
    result =
      case PointsHelper.validate_input_fields(user_id, reward_pool_limit) do
        {:error, :coworker_nil} ->
          put_flash(conn, :error, "Select user to change his reward pool")
          |> redirect(to: Routes.admin_path(conn, :new))

        {:error, :points_nil} ->
          put_flash(conn, :error, "Input reward pool limit")
          |> redirect(to: Routes.admin_path(conn, :new))

        {:error, :points_negative} ->
          put_flash(conn, :error, "Limit can't be less than 1 point")
          |> redirect(to: Routes.admin_path(conn, :new))

        {:ok, _new_points} ->
          :ok
      end

    if result == :ok do
      case AdminHelper.update_user_reward_pool_limit(user_id, reward_pool_limit) do
        {:ok, %User{name: name, surname: surname, points_limit: points_limit}} ->
          put_flash(
            conn,
            :info,
            "Changed user's #{name} #{surname} reward pool limit to #{points_limit}."
          )
          |> redirect(to: Routes.admin_path(conn, :new))

        {:error, _changeset} ->
          put_flash(conn, :info, "Something went wrong, check the form for issues")
          |> redirect(to: Routes.admin_path(conn, :new))
      end
    end
  end

  def show(conn, _params) do
    recent_points_log = AdminHelper.get_recent_points_history()
    render(conn, "show.html", recent_points_log: recent_points_log)
  end

  def reports(conn, _params) do
    render(conn, "reports.html", report_params: :report_params)
  end

  plug(:scrub_params, "report_params" when action in [:generate_reports])

  def generate_reports(conn, %{"report_params" => %{"year" => year, "month" => month}}) do
    {point_log, point_sum} =
      case {year, month} do
        {nil, _month} ->
          put_flash(conn, :error, "Something went wrong, check the form for issues")
          |> redirect(to: Routes.admin_path(conn, :reports))

        {year, nil} ->
          AdminHelper.generate_report(year)

        {year, month} ->
          AdminHelper.generate_report(year, month)
      end

    if Enum.any?(point_log) do
      case {year, month} do
        {nil, _month} ->
          put_flash(conn, :error, "Something went wrong, check the form for issues")
          |> redirect(to: Routes.admin_path(conn, :reports))

        {year, nil} ->
          render(conn, "single_report.html",
            points_log: point_log,
            points_sum: point_sum,
            year: year,
            month: nil
          )

        {year, _month} ->
          render(conn, "single_report.html",
            points_log: point_log,
            points_sum: point_sum,
            year: year,
            month: PointsHelper.get_month_string(Enum.at(point_log, 0, :month)),
            target: "_blank"
          )
      end
    else
      put_flash(conn, :error, "There are no records for given period")
      |> redirect(to: Routes.admin_path(conn, :reports))
    end
  end
end
