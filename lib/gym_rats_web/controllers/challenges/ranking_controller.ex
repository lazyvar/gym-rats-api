defmodule GymRatsWeb.Challenge.RankingController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Challenge, Account, Membership}
  alias GymRatsWeb.RankingView

  import Ecto.Query
  import Logger

  def index(conn, %{"score_by" => score_by, "challenge_id" => challenge_id}, account_id) do
    membership =
      Membership
      |> where([m], m.challenge_id == ^challenge_id and m.gym_rats_user_id == ^account_id)
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "You are not part of this challenge.")

      _ ->
        rankings_query =
          case score_by do
            "workouts" -> workout_rankings(challenge_id)
            _ -> score_by_rankings(challenge_id, score_by)
          end

        %{:rows => rows} = Repo |> Ecto.Adapters.SQL.query!(rankings_query, [])

        rankings =
          rows
          |> Enum.map(fn [score | [gym_rats_user_id | []]] ->
            score =
              case score_by do
                "workouts" -> score
                _ -> round(score) |> format
              end

            account = Account |> Repo.get!(gym_rats_user_id)
            %{score: "#{score}", account: account}
          end)

        success(conn, RankingView.default(rankings))
    end
  end

  def index(conn, %{"challenge_id" => challenge_id}, account_id) do
    challenge = Challenge |> Repo.get!(challenge_id)

    index(conn, %{"score_by" => challenge.score_by, "challenge_id" => challenge_id}, account_id)
  end

  defp format(number) do
    number
    |> Integer.to_char_list()
    |> Enum.reverse()
    |> Enum.chunk_every(3, 3, [])
    |> Enum.join(",")
    |> String.reverse()
  end

  defp score_by_rankings(challenge_id, score_by) do
    query = """
      SELECT 
        SUM(COALESCE(CAST(workout.#{score_by} as float), 0)) as total,
        account.id
      FROM 
        gym_rats_users account
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge_id}) workout
      ON
        workout.id = account.id
      WHERE
        account.id 
        IN (
          SELECT gym_rats_user_id FROM memberships WHERE challenge_id = #{challenge_id}
        )
      GROUP BY 
        account.id
      ORDER BY
        total DESC
    """
  end

  defp workout_rankings(challenge_id) do
    query = """
      SELECT 
        COUNT(workout) as total, 
        account.id
      FROM 
        gym_rats_users account
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge_id}) workout
      ON
        workout.id = account.id
      WHERE
        account.id 
        IN (
          SELECT gym_rats_user_id FROM memberships WHERE challenge_id = #{challenge_id}
        )
      GROUP BY 
        account.id
      ORDER BY
        total DESC
    """
  end
end
