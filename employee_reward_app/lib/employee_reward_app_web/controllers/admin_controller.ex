defmodule EmployeeRewardAppWeb.AdminController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.AdminHelper
  alias EmployeeRewardApp.User

  plug(:scrub_params, "user" when action in [:create])

  def new(conn, _params) do
    current_user = conn.assigns.current_user.id
    changeset = User.points_limit_changeset(%User{}, %{})
    user_list = AdminHelper.get_user_list(current_user)
    render(conn, "new.html", changeset: changeset, users: user_list)
  end


end
