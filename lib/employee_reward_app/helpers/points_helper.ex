defmodule EmployeeRewardApp.PointsHelper do

  import Ecto.Query

  alias EmployeeRewardApp.Repo
  alias EmployeeRewardApp.AddPoint
  alias EmployeeRewardApp.User
  alias EmployeeRewardApp.GivenPoint
  alias EmployeeRewardApp.ReceivedPoint
  alias EmployeeRewardApp.UserHelper


  def populate_points_panel(user_id) do
    month_string = get_month_string()
    {year, month} = get_month_year_int()
    changeset = AddPoint.changeset(%AddPoint{}, %{})

    users = UserHelper.get_user_list(user_id)
    current_user_points = get_user_given_points(user_id, year, month)
    points_history = get_user_transactions(user_id)
    points_limit = get_user_points_limit(user_id)

    points_history =
      for log <- points_history do
        Map.put_new(log, :month, get_month_string(log.date))
      end

    %{
      current_points: current_user_points,
      points_limit: points_limit,
      month: month_string,
      users: users,
      points_history: points_history,
      changeset: changeset
    }
  end

  def validate_input_fields(target_user, points) do
    points =
      if points != nil do
        case Integer.parse(points) do
          {parsed_points, _float} ->
            parsed_points

          :error ->
            nil
        end
      end

    case {target_user, points} do
      {nil, _points} ->
        {:error, :coworker_nil}

      {_user, nil} ->
        {:error, :points_nil}

      {_user, points} when points < 1 ->
        {:error, :points_negative}

      {_default, _def} ->
        {:ok, points}
    end
  end

  def validate_points(source_user, target_user, points) do
    {year, month} = get_month_year_int()
    points_limit = get_user_points_limit(source_user)

    case Repo.get_by(GivenPoint, user_id: source_user, year: year, month: month) do
      %GivenPoint{points_given: allocated_points, user_id: _id, month: _month, year: _year}
      when allocated_points + points <= points_limit ->
        update_user_given_points(
          source_user,
          target_user,
          year,
          month,
          allocated_points + points,
          points
        )

      nil ->
        insert_new_given_points_record(0, source_user, year, month)

      _default ->
        :error
    end
  end

  defp get_user_given_points(source_user, year, month) do
    case Repo.get_by(GivenPoint, user_id: source_user, year: year, month: month) do
      %GivenPoint{points_given: allocated_points} ->
        allocated_points

      nil ->
        insert_new_given_points_record(0, source_user, year, month)
        get_user_given_points(source_user, year, month)
    end
  end

  defp insert_new_given_points_record(points, user, year, month) do
    %GivenPoint{}
    |> GivenPoint.changeset(%{
      points_given: points,
      user_id: user,
      year: year,
      month: month
    })
    |> Repo.insert()
  end

  defp update_user_given_points(
         source_user,
         target_user,
         year,
         month,
         points_to_update,
         points_assigned
       ) do
    user_receiving = Repo.get_by(User, id: target_user)

    GivenPoint
    |> Repo.get_by(user_id: source_user, year: year, month: month)
    |> GivenPoint.changeset(%{points_given: points_to_update})
    |> Repo.update()

    log_transaction(points_assigned, source_user, target_user)
    receive_points(target_user, points_assigned, year, month)

    {:ok,
     %{
       points_assigned: Integer.to_string(points_assigned),
       target_name: user_receiving.name,
       target_surname: user_receiving.surname,
       target_email: user_receiving.email
     }}
  end

  defp log_transaction(points, source_user, target_user) do
    {year, month} = get_month_year_int()
    %AddPoint{}
    |> AddPoint.changeset(%{
      points_given: points,
      receiving_user_id: target_user,
      giving_user_id: source_user,
      year: year,
      month: month
    })
    |> Repo.insert()
  end

  defp receive_points(target_user, points, year, month) do
    case get_user_received_points(target_user, year, month) do
      %ReceivedPoint{points_received: previous_points} ->
        update_received_points(previous_points + points, target_user, year, month)

      nil ->
        insert_new_received_points_record(target_user, points, year, month)
    end
  end

  defp get_user_received_points(target_user, year, month) do
    Repo.get_by(ReceivedPoint, user_id: target_user, year: year, month: month)
  end

  defp get_user_points_limit(user_id) do
    query = from(u in User,
    where: u.id == ^user_id,
    select: u.points_limit)

    Repo.one(query)
  end

  def get_all_users_received_points(user_id) do
    query =
      from(r in ReceivedPoint,
        where: r.user_id == ^user_id,
        order_by: [desc: [r.month, r.year]],
        limit: 30,
        select: %{
          points_received: r.points_received,
          month: r.month,
          year: r.year
        }
      )

    Repo.all(query)
  end

  def get_user_points_this_month(user_id) do
    {year, month} = get_month_year_int()

    case get_user_received_points(user_id, year, month) do
      %ReceivedPoint{points_received: previous_points} ->
        previous_points

      nil ->
        insert_new_received_points_record(user_id, 0, year, month)
        get_user_points_this_month(user_id)
    end
  end

  defp update_received_points(points_sum, user, year, month) do
    get_user_received_points(user, year, month)
    |> ReceivedPoint.changeset(%{points_received: points_sum})
    |> Repo.update()
  end

  defp insert_new_received_points_record(user, points, year, month) do
    %ReceivedPoint{}
    |> ReceivedPoint.changeset(%{
      user_id: user,
      points_received: points,
      year: year,
      month: month
    })
    |> Repo.insert()
  end

  # Returns: logs of all points given away by current_user
  defp get_user_transactions(current_user) do
    query =
      from(a in AddPoint,
        join: u in User,
        on: u.id == a.receiving_user_id,
        where: a.giving_user_id == ^current_user,
        order_by: [desc: a.inserted_at],
        limit: 30,
        select: %{
          giving_user: a.giving_user_id,
          target_user: a.receiving_user_id,
          target_user_name: u.name,
          target_user_surname: u.surname,
          points: a.points_given,
          date: a.inserted_at
        }
      )

    Repo.all(query)
  end

  defp get_month_string() do
    Calendar.strftime(DateTime.utc_now(), "%B")
  end

  def get_month_string(date_time_struct) do
    Calendar.strftime(date_time_struct, "%B")
  end

  # pattern match return with {year, month}
  defp get_month_year_int() do
    {DateTime.utc_now().year, DateTime.utc_now().month}
  end
end
