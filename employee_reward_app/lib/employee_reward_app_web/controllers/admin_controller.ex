defmodule EmployeeRewardAppWeb.AdminController do
  use EmployeeRewardAppWeb, :controller

  alias EmployeeRewardApp.AdminHelper
  alias EmployeeRewardApp.User

  plug(:scrub_params, "user" when action in [:create])

  def new(conn, _params) do
    current_user = conn.assigns.current_user.id
    points_limit_changeset = User.points_limit_changeset(%User{}, %{})
    user_list = AdminHelper.get_user_list(current_user)
    recent_points_log = AdminHelper.get_recent_points_history()
    render(conn, "new.html", points_limit_changeset: points_limit_changeset, users: user_list, recent_points_log: recent_points_log)
  end


end
