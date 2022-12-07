defmodule EmployeeRewardAppWeb.UserController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.User
  alias EmployeeRewardApp.UserHelper

  plug(:scrub_params, "user" when action in [:create])

  def show(conn, _params) do
    user_id = conn.assigns.current_user.id
    user = Repo.get!(User, user_id)
    points = EmployeeRewardApp.PointsHelper.get_user_points_this_month(user_id)
    render(conn, "show.html", user: user, points: points)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case UserHelper.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User #{user.name} #{user.surname} created!")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def change_password(conn, %{
        "session" => %{"check_password" => check_password, "password" => new_password}
      }) do
    user_id = conn.assigns.current_user.id

    case UserHelper.change_password(user_id, check_password, new_password) do
      {:ok, _password_set} ->
        conn
        |> EmployeeRewardAppWeb.SessionController.logout()
        |> put_flash(:info, "Password succesfully changed. Log in with Your new password.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Invalid password")
        |> redirect(to: Routes.user_path(conn, :settings))
      {:error, changeset} ->
        conn
        |> render("settings.html", changeset: changeset)
    end
  end

  def rewards(conn, _params) do
    render(conn, "rewards.html")
  end

  def settings(conn, _params) do
    changeset = %User{} |> User.password_changeset(%{})
    render(conn, "settings.html", changeset: changeset)
  end
end
