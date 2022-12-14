defmodule EmployeeRewardApp.Email do
  import Swoosh.Email

  def points_email(target_email, points_amount) do
    new()
    |> to(target_email)
    |> from("employee.rewards.app@gmail.com")
    |> subject("You have received a reward from your co-worker!")
    |> html_body("<strong>You have been awarded #{points_amount} points from your co-worker</strong>")

  end

end
