defmodule GymRatsWeb.Team.RankingController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Challenge, Account, Membership, Team}
  alias GymRatsWeb.RankingView
  alias GymRats.NumberFormatter

  import Ecto.Query
  import Logger

  def index(conn, %{"score_by" => score_by, "team_id" => team_id}, account_id) do
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
        rankings_query =
          case score_by do
            "workouts" -> workout_rankings(challenge_id, team_id)
            _ -> score_by_rankings(challenge_id, team_id, score_by)
          end

        %{:rows => rows} = Repo |> Ecto.Adapters.SQL.query!(rankings_query, [])

        case rows do
          [[0, nil]] ->
            success(conn, [])

          _ ->
            rankings =
              rows
              |> Enum.map(fn [score | [gym_rats_user_id | []]] ->
                score =
                  case score_by do
                    "workouts" ->
                      score

                    "distance" ->
                      :erlang.float_to_binary(score, decimals: 1) |> NumberFormatter.format()

                    _ ->
                      round(score) |> NumberFormatter.format()
                  end

                account = Account |> Repo.get!(gym_rats_user_id)
                %{score: "#{score}", account: account}
              end)

            success(conn, RankingView.default(rankings))
        end
    end
  end

  def index(conn, %{"team_id" => team_id}, account_id) do
    team = Team |> Repo.get!(team_id)
    challenge = Challenge |> Repo.get!(team.challenge_id)

    index(conn, %{"score_by" => challenge.score_by, "team_id" => team_id}, account_id)
  end

  defp score_by_rankings(challenge_id, team_id, score_by) do
    """
    SELECT 
      SUM(COALESCE(CAST(w.#{score_by} as float), 0)) as total,
      tm.account_id
    FROM 
      (SELECT * FROM teams where id = #{team_id}) t
    LEFT JOIN
      team_memberships tm
    ON 
      t.id = tm.team_id
    LEFT JOIN
      (SELECT * FROM workouts WHERE challenge_id = #{challenge_id}) w
    ON
      w.gym_rats_user_id = tm.account_id
    GROUP BY 
      tm.account_id
    ORDER BY
      total DESC
    """
  end

  defp workout_rankings(challenge_id, team_id) do
    """
    SELECT 
      COUNT(w) as total,
      tm.account_id
    FROM 
      (SELECT * FROM teams where id = #{team_id}) t
    LEFT JOIN
      team_memberships tm 
    ON 
      t.id = tm.team_id
    LEFT JOIN
      (SELECT * FROM workouts WHERE challenge_id = #{challenge_id}) w
    ON
      w.gym_rats_user_id = tm.account_id
    GROUP BY 
      tm.account_id
    ORDER BY
      total DESC
    """
  end
end
