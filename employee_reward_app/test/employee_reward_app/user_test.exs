defmodule EmployeeRewardApp.UserTest do
  use EmployeeRewardApp.DataCase

  alias EmployeeRewardApp.User

  @valid_attrs %{email: "bobody@gmail.com", name: "Michael", surname: "Scott", password: "123456", department: "Manager", is_admin: 0}
  @valid_changeset %User{email: "bobody@gmail.com", name: "Michael", surname: "Scott", password: "123456", department: "Manager", is_admin: 0}
  @invalid_email %{email: "emailAthost.com", name: "Noname", surname: "Nobody", password: "123456", department: "None", is_admin: 0}
  @invalid_password_set %{email: "email@host.com", name: "Name", surname: "Bobody", password: "12345", department: "Some", is_admin: 1}
  @valid_password %{password: "123456"}
  @invalid_password %{password: "12345"}

  test "valid registration changeset" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "registration changeset - invalid email" do
    changeset = User.registration_changeset(%User{}, @invalid_email)
    refute changeset.valid?
  end

  test "registration changeset - invalid password" do
    changeset = User.registration_changeset(%User{}, @invalid_password_set)
    refute changeset.valid?
  end

  test "change password changeset - valid new password" do
    changeset = User.password_changeset(@valid_changeset, @valid_password)
    assert changeset.valid?
  end

  test "change password changeset - invalid new password" do
    changeset = User.password_changeset(@valid_changeset, @invalid_password)
    refute changeset.valid?
  end

  test "password hash" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert Bcrypt.verify_pass(@valid_attrs.password, changeset.changes.password_hash) == true
  end

end
