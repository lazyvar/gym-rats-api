defmodule GymRatsWeb.Challenge.GroupStatsController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.{AccountView}
  alias GymRats.Model.{Challenge, Account, Workout, Membership}
  alias GymRats.{Repo, NumberFormatter}

  import Ecto.Query

  def group_stats(conn, %{"challenge_id" => challenge_id, "utc_offset" => utc_offset}, account_id) do
    membership =
      Membership
      |> where([m], m.challenge_id == ^challenge_id and m.gym_rats_user_id == ^account_id)
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "You are not part of this challenge.")

      _ ->
        {early_riser, number_of_workouts} =
          most_early_bird_workouts(challenge_id, utc_offset) || {account_id, 0}

        early_riser = Account |> Repo.get(early_riser)
        challenge = Challenge |> Repo.get(challenge_id)

        total_score =
          String.to_float(total_score(challenge_id)) |> NumberFormatter.format_score(challenge)

        success(conn, %{
          total_workouts: total_workouts(challenge_id),
          total_score: "#{total_score}",
          most_early_bird_workouts: %{
            account: AccountView.default(early_riser),
            number_of_workouts: number_of_workouts
          }
        })
    end
  end

  defp total_workouts(challenge_id) do
    Workout
    |> where([w], w.challenge_id == ^challenge_id)
    |> select(count("*"))
    |> Repo.one()
  end

  defp total_score(challenge_id) do
    query =
      from w in Workout,
        where: w.challenge_id == ^challenge_id,
        select: coalesce(sum(type(w.points, :float)), 0)

    query |> Repo.one() |> NumberFormatter.format()
  end

  defp most_early_bird_workouts(challenge_id, utc_offset) do
    query =
      from w in Workout,
        group_by: w.gym_rats_user_id,
        select: {w.gym_rats_user_id, count(w.id)},
        where:
          w.challenge_id == ^challenge_id and
            fragment("extract(hour from created_at at time zone ?) < 9", ^utc_offset),
        order_by: [desc: count(w.id)],
        limit: 1

    query |> Repo.one()
  end

  defp haleiuigh do
    # total_workouts:
    # total_score:
    # most_early_bird_workouts:
  end
end
