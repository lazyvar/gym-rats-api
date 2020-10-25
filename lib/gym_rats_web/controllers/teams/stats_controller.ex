defmodule GymRatsWeb.Team.StatsController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Membership, Team}
  alias GymRats.NumberFormatter

  import Ecto.Query

  def stats(conn, %{"team_id" => team_id}, account_id) do
    team = Team |> Repo.get!(team_id)
    challenge_id = team.challenge_id

    membership =
      Membership
      |> where([m], m.challenge_id == ^challenge_id and m.gym_rats_user_id == ^account_id)
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "You are not part of this challenge.")

      _ ->
        %{:rows => [[duration, distance, steps, calories, points, workouts]]} =
          Repo |> Ecto.Adapters.SQL.query!(stats_query(team), [])

        success(conn, %{
          duration: round(duration) |> NumberFormatter.format(),
          distance: :erlang.float_to_binary(distance, decimals: 1) |> NumberFormatter.format(),
          steps: round(steps) |> NumberFormatter.format(),
          calories: round(calories) |> NumberFormatter.format(),
          points: round(points) |> NumberFormatter.format(),
          workouts: workouts
        })
    end
  end

  def stats(conn, _params, _account_id), do: failure(conn, "Invalid format")

  defp stats_query(team) do
    """
    SELECT 
      SUM(COALESCE(CAST(w.duration as float), 0)) as total_duration,
      SUM(COALESCE(CAST(w.distance as float), 0)) as total_distance,
      SUM(COALESCE(CAST(w.steps as float), 0)) as total_steps,
      SUM(COALESCE(CAST(w.calories as float), 0)) as total_calories,
      SUM(COALESCE(CAST(w.points as float), 0)) as total_points,
      COUNT(w) as total_workouts
    FROM 
      (SELECT * FROM teams where id = #{team.id}) t
    LEFT JOIN
      team_memberships tm 
    ON 
      t.id = tm.team_id
    LEFT JOIN
      (SELECT * FROM workouts WHERE challenge_id = #{team.challenge_id}) w
    ON
      w.gym_rats_user_id = tm.account_id
    """
  end
end
