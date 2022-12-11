defmodule EmployeeRewardApp.PointsHelperTest do
  use EmployeeRewardApp.DataCase

  alias EmployeeRewardApp.PointsHelper

  @input_user_id "5"
  @input_points "15"
  @invalid_input_points_only_letters "abc"
  @invalid_input_points_negative "-15"
  @invalid_input_points_zero "0"

  test "populate points panel returns correct map" do
  end

  test "valid input fields" do
    assert PointsHelper.validate_input_fields(@input_user_id, @input_points) ==
             {:ok, String.to_integer(@input_points)}
  end

  test "invalid input fields" do
    assert PointsHelper.validate_input_fields(@input_user_id, @invalid_input_points_only_letters) ==
            {:error, :points_nil}
    assert PointsHelper.validate_input_fields(@input_user_id, @invalid_input_points_negative) ==
            {:error, :points_negative}
    assert PointsHelper.validate_input_fields(@input_user_id, @invalid_input_points_zero) ==
            {:error, :points_negative}
  end

end
