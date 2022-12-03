defmodule EmployeeRewardApp.Guardian do
  use Guardian, otp_app: :employee_reward_app

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    user = EmployeeRewardApp.Repo.get(EmployeeRewardApp.User, id)
    {:ok, user}
  end
end
