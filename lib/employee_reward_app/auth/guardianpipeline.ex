defmodule EmployeeRewardApp.AuthAccessPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :employee_reward_app,
    module: EmployeeRewardApp.Guardian,
    error_handler: EmployeeRewardApp.AuthErrorHandler

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, allow_blank: false)
end
