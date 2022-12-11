defmodule EmployeeRewardAppWeb.PointsControllerTest do
  use EmployeeRewardAppWeb.ConnCase

  @add_points_attrs %{"add_point" => %{"points_given" => 15, "user_id" => 3}}


  test "redirect", %{conn: conn} do
    conn = post(conn, Routes.points_path(conn, :create), post: @add_points_attrs)
    assert redirected_to(conn) == Routes.points_path(conn, :new)
  end

end
