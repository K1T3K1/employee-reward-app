defmodule EmployeeRewardApp.User do
  use Ecto.Schema
  import Ecto.Changeset
  @required_fields [:email, :name, :surname, :password, :department, :is_admin]
  schema "users" do
    field :email, :string
    field :name, :string
    field :surname, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :department, :string
    field :is_admin, :integer
    field :points_limit, :integer, default: 50

    timestamps()
  end

  def changeset(user, attrs) do
    cast(user, attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def registration_changeset(struct, params) do
    changeset(struct, params)
    |> cast(params, [:password, :email], [])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> hash_password
  end

  def password_changeset(struct, params) do
    changeset(struct, params)
    |> cast(params, [:password, :id])
    |> validate_length(:password, min: 6, max: 100)
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(
          changeset,
          :password_hash,
          Bcrypt.hash_pwd_salt(password)
        )

      _empty ->
        changeset
    end
  end

  def points_limit_changeset(struct, params) do
    struct
    |> cast(params, [:points_limit])
    |> validate_required([:points_limit])
  end
end
