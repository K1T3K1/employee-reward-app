#defmodule EmployeeRewardAppWeb.AdminController do
#  use EmployeeRewardAppWeb, :controller
#
#  alias EmployeeRewardApp.Repo
#  alias EmployeeRewardApp.User
#
#  plug(:scrub_params, "user" when action in [:create])
#
#  def show(conn, %{"id" => id}) do
#    user = Repo.get!(User, id)
#    render(conn, "show.html", user: user)
#  end
#
#  def new(conn, _params) do
#    changeset = User.changeset(%User{}, %{})
#    render(conn, "new.html", changeset: changeset)
#  end
#
#  def create(conn, %{"user" => user_params}) do
#    changeset = %User{} |> User.registration_changeset(user_params, is_admin: 1)
#
#    case Repo.insert(changeset) do
#      {:ok, user} ->
#        conn
#        |> put_flash(:info, "Admin #{user.name} #{user.surname} created!")
#        |> redirect(to: Routes.admin_path(conn, :show, user))
#
#      {:error, changeset} ->
#        render(conn, "new.html", changeset: changeset)
#    end
#  end
#end
#
  