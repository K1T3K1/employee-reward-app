defmodule EmployeeRewardAppWeb.UserController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.User

  plug(:scrub_params, "user" when action in [:create])

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    points = EmployeeRewardAppWeb.PointsController.get_user_points_this_month(id)
    render(conn, "show.html", user: user, points: points)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params = Map.put_new(user_params, "is_admin", 0)
    changeset = %User{} |> User.registration_changeset(user_params)

    case Repo.insert(changeset) |> IO.inspect() do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User #{user.name} #{user.surname} created!")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def change_password(conn, %{"session" => %{"check_password" => check_password, "new_password" => new_password}}) do
    user_id = conn.assigns.current_user.id
    user = Repo.get_by(User, id: user_id)
    result = cond do
      user && Bcrypt.verify_pass(check_password, user.password_hash) ->
        {:ok, update_password(user, new_password)}

        user ->
          {:error, :unauthorized, conn}

        true ->
          Bcrypt.no_user_verify()
          {:error, :not_found, conn}
    end

    case result do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Password succesfully changed")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid password")
        |> render("new.html")
    end
  end

  defp update_password(user, new_password) do
    user
    |> User.password_changeset(%{password: new_password})
    |> Repo.update()
  end

  def rewards(conn, _params) do
    render(conn, "rewards.html")
  end

  def settings(conn, _params) do
    render(conn, "settings.html")
  end
end
