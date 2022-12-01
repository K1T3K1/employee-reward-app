defmodule EmployeeRewardApp.AuthErrorHandler do
  import Plug.Conn
  @behaviour Guardian.Plug.ErrorHandler

  def auth_error(conn, {type, reason}, _opts) do
    EmployeeRewardAppWeb.SessionController.user_unauthorized(conn)
  end
end
