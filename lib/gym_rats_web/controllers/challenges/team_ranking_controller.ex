defmodule GymRatsWeb.Challenge.TeamRankingController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Challenge, Team, Membership}
  alias GymRatsWeb.TeamRankingView
  alias GymRats.NumberFormatter

  import Ecto.Query

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
          |> Enum.map(fn [score | [team_id | []]] ->
            score =
              case score_by do
                "workouts" ->
                  score

                "distance" ->
                  :erlang.float_to_binary(score, decimals: 1) |> NumberFormatter.format()

                _ ->
                  round(score) |> NumberFormatter.format()
              end

            team = Team |> Repo.get!(team_id)
            %{score: "#{score}", team: team}
          end)

        success(conn, TeamRankingView.default(rankings))
    end
  end

  def index(conn, %{"challenge_id" => challenge_id}, account_id) do
    challenge = Challenge |> Repo.get!(challenge_id)

    index(conn, %{"score_by" => challenge.score_by, "challenge_id" => challenge_id}, account_id)
  end

  defp score_by_rankings(challenge_id, score_by) do
    """
      SELECT 
        SUM(COALESCE(CAST(w.#{score_by} as float), 0)) as total,
        t.id
      FROM 
        (SELECT * FROM teams where challenge_id = #{challenge_id}) t
      LEFT JOIN
        team_memberships tm 
      ON 
        t.id = tm.team_id
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge_id}) w
      ON
        w.gym_rats_user_id = tm.account_id
      GROUP BY 
        t.id
      ORDER BY
        total DESC
    """
  end

  defp workout_rankings(challenge_id) do
    """
      SELECT 
        COUNT(w) as total,
        t.id
      FROM 
        (SELECT * FROM teams where challenge_id = #{challenge_id}) t
      LEFT JOIN
        team_memberships tm 
      ON 
        t.id = tm.team_id
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge_id}) w
      ON
        w.gym_rats_user_id = tm.account_id
      GROUP BY 
        t.id
      ORDER BY
        total DESC
    """
  end
end
