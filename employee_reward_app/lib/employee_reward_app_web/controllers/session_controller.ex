defmodule EmployeeRewardAppWeb.SessionController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.User
  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.Guardian

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    user = Repo.get_by(User, email: email)

    result = cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        Bcrypt.no_user_verify()
        {:error, :not_found, conn}
    end

    case result do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "You're now logged in")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render("new.html")
    end
  end

  defp login(conn, user) do
    Guardian.Plug.sign_in(conn, user)
  end

  def delete(conn, _params) do

  end

end
