defmodule EmployeeRewardApp.UserHelper do

  import Ecto.Query

  alias EmployeeRewardApp.Department
  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.User

  def register_user(user_params) do
    user_params = Map.put_new(user_params, "is_admin", 0)
    changeset = %User{} |> User.registration_changeset(user_params)

    Repo.insert(changeset)
  end

  def change_password(user_id, check_password, new_password) do
      user = Repo.get_by(User, id: user_id)
      cond do
        user && Bcrypt.verify_pass(check_password, user.password_hash) ->
          update_password(user, new_password)

        user ->
          {:error, :unauthorized}

        true ->
          Bcrypt.no_user_verify()
          {:error, :unauthorized}
      end
  end

  defp update_password(user, new_password) do
    user
    |> User.password_changeset(%{password: new_password})
    |> Repo.update()
  end

  # retrieve all users from db, but without current_user
  # Returns: list of %User{}
  def get_user_list(current_user) do
    query =
      from(u in User,
        where: u.id != ^current_user,
        select: %{id: u.id, name: u.name, surname: u.surname, department: u.department}
      )

    Repo.all(query)
  end

  # Returns: list containing all %User{} records from db
  def get_user_list() do
    Repo.all(User)
  end

end
