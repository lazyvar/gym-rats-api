defmodule GymRatsWeb.Challenge.InfoController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Account, Workout, Challenge}
  alias GymRatsWeb.AccountView
  alias GymRats.Repo

  import Ecto.Query

  def info(conn, %{"challenge_id" => challenge_id}, account_id) do
    member_count =
      Account
      |> join(:left, [a], c in assoc(a, :memberships))
      |> where([a, m], a.id == m.gym_rats_user_id and m.challenge_id == ^challenge_id)
      |> select(count("*"))
      |> Repo.one()

    workout_count =
      Workout
      |> join(:left, [w], c in assoc(w, :challenge))
      |> where([w, c], w.challenge_id == ^challenge_id)
      |> select(count("*"))
      |> Repo.one()

    challenge = Challenge |> Repo.get!(challenge_id)

    leader_q =
      case challenge.score_by do
        "workouts" -> workouts_leader_query(challenge)
        _ -> leader_query(challenge)
      end

    current_account_q =
      case challenge.score_by do
        "workouts" -> workouts_for_account(challenge, account_id)
        _ -> score_for_account(challenge, account_id)
      end

    if workout_count != 0 do
      %{:rows => [[leader_score | [leader_id | _]]]} =
        Ecto.Adapters.SQL.query!(Repo, leader_q, [])

      %{:rows => [[current_account_score] | _]} =
        Ecto.Adapters.SQL.query!(Repo, current_account_q, [])

      leader = Account |> Repo.get!(leader_id)

      leader_score = leader_score |> format_score(challenge)
      current_account_score = (current_account_score || 0.0) |> format_score(challenge)
            
      success(conn, %{
        member_count: member_count,
        workout_count: workout_count,
        leader: AccountView.default(leader),
        leader_score: "#{leader_score}",
        current_account_score: "#{current_account_score}"
      })
    else
      leader_id = account_id
      leader_score = "-"
      current_account_score = "-"

      leader = Account |> Repo.get!(leader_id)

      success(conn, %{
        member_count: member_count,
        workout_count: workout_count,
        leader: AccountView.default(leader),
        leader_score: "#{leader_score}",
        current_account_score: "#{current_account_score}"
      })
    end
  end

  defp format_score(score, challenge) do
    case challenge.score_by do
      "workouts" -> score
      "distance" -> :erlang.float_to_binary(score, decimals: 1) |> format_float
      _ -> round(score) |> format_int
    end
  end

  defp workouts_leader_query(challenge) do
    """
    SELECT 
      COUNT(workout) as total,
      account.id
    FROM 
      gym_rats_users account
    LEFT JOIN
      (SELECT * FROM workouts WHERE challenge_id = #{challenge.id}) workout
    ON
      workout.gym_rats_user_id = account.id
    WHERE
      account.id 
      IN (
        SELECT gym_rats_user_id FROM memberships WHERE challenge_id = #{challenge.id}
      )
    GROUP BY 
      account.id
    ORDER BY
      total DESC
    LIMIT 1
    """
  end

  defp workouts_for_account(challenge, account_id) do
    """
    SELECT 
      COUNT(*) as total
    FROM 
      workouts
    WHERE
      challenge_id = #{challenge.id}
    AND
      gym_rats_user_id = #{account_id}
    """
  end

  defp leader_query(challenge) do
    """
      SELECT 
        SUM(COALESCE(CAST(workout.#{challenge.score_by} as float), 0)) as total,
        account.id
      FROM 
        gym_rats_users account
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge.id}) workout
      ON
        workout.gym_rats_user_id = account.id
      WHERE
        account.id 
        IN (
          SELECT gym_rats_user_id FROM memberships WHERE challenge_id = #{challenge.id}
        )
      GROUP BY 
        account.id
      ORDER BY
        total DESC
      LIMIT 1
    """
  end

  defp score_for_account(challenge, account_id) do
    """
      SELECT 
        SUM(COALESCE(CAST(#{challenge.score_by} as float), 0))
      FROM 
        workouts
      WHERE
        challenge_id = #{challenge.id}
      AND
        gym_rats_user_id = #{account_id}
    """
  end

  defp format_int(number) do
    number
    |> Integer.to_char_list()
    |> Enum.reverse()
    |> Enum.chunk_every(3, 3, [])
    |> Enum.join(",")
    |> String.reverse()
  end

  def format_float(number) do
    number
    |> to_string
    |> String.replace(~r/\d+(?=\.)|\A\d+\z/, fn(int) ->
      int
      |> String.graphemes
      |> Enum.reverse
      |> Enum.chunk_every(3, 3, [])
      |> Enum.join(",")
      |> String.reverse
    end)
  end
end
