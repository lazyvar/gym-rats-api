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
            if is_float(score) do
              score = :erlang.float_to_binary(score, [decimals: 2])
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

  defp score_by_rankings(challenge_id, score_by) do
    query = """
      SELECT 
        SUM(COALESCE(CAST(#{score_by} as float), 0)) as total,
        gym_rats_user_id
      FROM 
        workouts
      WHERE
        challenge_id = #{challenge_id}
      GROUP BY gym_rats_user_id
      ORDER BY
        total DESC
    """
  end

  defp workout_rankings(challenge_id) do
    query = """
      SELECT 
        COUNT(*) as total, 
        gym_rats_user_id
      FROM 
        workouts
      WHERE
        challenge_id = #{challenge_id}
      GROUP BY gym_rats_user_id
      ORDER BY
        total DESC
    """
  end
end
