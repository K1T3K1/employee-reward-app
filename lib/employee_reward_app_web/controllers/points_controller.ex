defmodule EmployeeRewardAppWeb.PointsController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.PointsHelper

  plug(:scrub_params, "add_point" when action in [:create])

  def new(conn, _param) do
    user = Guardian.Plug.current_resource(conn)

    %{
      current_points: current_points,
      points_limit: points_limit,
      month: month,
      users: users,
      points_history: points_history,
      changeset: changeset
    } = PointsHelper.populate_points_panel(user.id)

    render(conn, "new.html",
      user: user,
      current_points: current_points,
      points_limit: points_limit,
      month: month,
      changeset: changeset,
      users: users,
      points_history: points_history
    )
  end

  def create(conn, %{"add_point" => points_params}) do
    source_user = conn.assigns.current_user.id
    %{"points_given" => points, "user_id" => target_user} = points_params

    result =
      case PointsHelper.validate_input_fields(target_user, points) do
        {:error, :coworker_nil} ->
          put_flash(conn, :error, "Select co-worker to be rewarded")
          |> redirect(to: Routes.points_path(conn, :new))

        {:error, :points_nil} ->
          put_flash(conn, :error, "Input amount of points to reward co-worker with")
          |> redirect(to: Routes.points_path(conn, :new))

        {:error, :points_negative} ->
          put_flash(conn, :error, "You have to assign at least 1 point!")
          |> redirect(to: Routes.points_path(conn, :new))

        {:ok, _new_points} ->
          :ok
      end

    if result == :ok do
      case PointsHelper.validate_points(source_user, target_user, String.to_integer(points)) do
        {:ok,
         %{
           points_assigned: points_assigned,
           target_name: target_name,
           target_surname: target_surname,
           target_email: target_email
         }} ->
          try do
            EmployeeRewardApp.Email.points_email(target_email, points_assigned) |> IO.inspect()
            |> EmployeeRewardApp.Mailer.deliver!() |> IO.inspect
          rescue
              _e in DeliveryError -> :failed_to_deliver
          end
            put_flash(
            conn,
            :info,
            points_assigned <>
              " " <> "points assigned to: " <> target_name <> " " <> target_surname
          )
          |> redirect(to: Routes.points_path(conn, :new))


        :error ->
          put_flash(
            conn,
            :error,
            "Select a co-worker and make sure you're not trying to assign over your monthly limit"
          )
          |> redirect(to: Routes.points_path(conn, :new))
      end
    end
  end
end
