defmodule EmployeeRewardApp.Email do
  import Swoosh.Email

  def points_email(target_email, points_amount) do
    new(
      to: target_email,
      from: "administrator@rewards.app",
      subject: "You have received a reward from your co-worker!",
      html_body: "<strong>You have been awarded #{points_amount}</strong>"
    )
  end

end
