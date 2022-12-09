defmodule EmployeeRewardApp.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  def auth_error(conn, {_type, _reason}, _opts) do
    EmployeeRewardAppWeb.SessionController.user_unauthorized(conn)
  end
end
