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

      if is_float(leader_score) do
        leader_score = :erlang.float_to_binary(leader_score, [decimals: 0])
      end

      if is_float(current_account_score) do
        current_account_score = :erlang.float_to_binary(current_account_score, [decimals: 0])
      end

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

  defp workouts_leader_query(challenge) do
    """
      SELECT 
        COUNT(*) as total, 
        gym_rats_user_id
      FROM 
        workouts
      WHERE
        challenge_id = #{challenge.id}
      GROUP BY gym_rats_user_id
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
        SUM(COALESCE(CAST(#{challenge.score_by} as float), 0)) as total, 
        gym_rats_user_id
      FROM 
        workouts
      WHERE
        challenge_id = #{challenge.id}
      GROUP BY gym_rats_user_id
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
end
