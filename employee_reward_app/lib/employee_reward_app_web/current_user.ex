defmodule EmployeeRewardAppWeb.CurrentUser do
  import Plug.Conn
  alias EmployeeRewardApp.Guardian
  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
