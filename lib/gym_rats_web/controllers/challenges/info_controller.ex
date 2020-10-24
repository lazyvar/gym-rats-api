defmodule GymRatsWeb.Challenge.InfoController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Account, Workout, Challenge, Team, TeamMembership}
  alias GymRatsWeb.{TeamView, AccountView}
  alias GymRats.{Repo, NumberFormatter}

  import Ecto.Query

  def info(conn, %{"challenge_id" => challenge_id}, account_id) do
    team_membership =
      TeamMembership
      |> where([tm], tm.account_id == ^account_id)
      |> Repo.one()

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

    team_leader_q =
      case challenge.score_by do
        "workouts" -> team_workouts_leader_query(challenge)
        _ -> team_leader_query(challenge)
      end

    current_team_q =
      case team_membership do
        nil ->
          nil

        _ ->
          case challenge.score_by do
            "workouts" -> workouts_for_team(team_membership.team_id, challenge)
            _ -> score_for_team(team_membership.team_id, challenge)
          end
      end

    current_account_q =
      case challenge.score_by do
        "workouts" -> workouts_for_account(challenge, account_id)
        _ -> score_for_account(challenge, account_id)
      end

    if workout_count != 0 do
      %{:rows => [[leader_score | [leader_id | _]]]} =
        Ecto.Adapters.SQL.query!(Repo, leader_q, [])

      %{:rows => [[team_leader_score | [team_leader_id | _]]]} =
        Ecto.Adapters.SQL.query!(Repo, team_leader_q, [])

      %{:rows => [[current_account_score] | _]} =
        Ecto.Adapters.SQL.query!(Repo, current_account_q, [])

      current_team_score =
        case team_membership do
          nil ->
            "-"

          _ ->
            %{:rows => [[current_team_score] | _]} =
              Ecto.Adapters.SQL.query!(Repo, current_team_q, [])

            current_team_score
        end

      leader = Account |> Repo.get!(leader_id)

      team_leader =
        case team_leader_id do
          nil -> nil
          _ -> Team |> Repo.get!(team_leader_id)
        end

      leader_score = leader_score |> NumberFormatter.format_score(challenge)

      current_account_score =
        (current_account_score || 0.0) |> NumberFormatter.format_score(challenge)

      current_team =
        case team_membership do
          nil -> nil
          _ -> Team |> Repo.get!(team_membership.team_id)
        end

      success(conn, %{
        member_count: member_count,
        workout_count: workout_count,
        leader: AccountView.default(leader),
        team_leader:
          if team_leader do
            TeamView.default(team_leader)
          else
            nil
          end,
        current_team:
          if current_team do
            TeamView.default(current_team)
          else
            nil
          end,
        team_leader_score: "#{team_leader_score}",
        current_team_score: "#{current_team_score}",
        leader_score: "#{leader_score}",
        current_account_score: "#{current_account_score}"
      })
    else
      leader_id = account_id
      leader_score = "-"
      current_account_score = "-"
      team_leader_score = "-"
      current_team_score = "-"

      leader = Account |> Repo.get!(leader_id)

      team =
        case team_membership do
          nil -> nil
          _ -> Team |> Repo.get!(team_membership.team_id)
        end

      success(conn, %{
        member_count: member_count,
        workout_count: workout_count,
        leader: AccountView.default(leader),
        team_leader:
          if team do
            TeamView.default(team)
          else
            nil
          end,
        current_team:
          if team do
            TeamView.default(team)
          else
            nil
          end,
        team_leader_score: "#{team_leader_score}",
        current_team_score: "#{current_team_score}",
        leader_score: "#{leader_score}",
        current_account_score: "#{current_account_score}"
      })
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

  defp team_leader_query(challenge) do
    """
      SELECT
        SUM(COALESCE(CAST(w.#{challenge.score_by} as float), 0)) as total,
        t.id
      FROM
        (SELECT * FROM teams where challenge_id = #{challenge.id}) t
      LEFT JOIN
        team_memberships tm
      ON
        t.id = tm.team_id
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge.id}) w
      ON
        w.gym_rats_user_id = tm.account_id
      GROUP BY
        t.id
      HAVING
        COUNT(tm) > 0
      ORDER BY
        total DESC
      LIMIT 1
    """
  end

  defp team_workouts_leader_query(challenge) do
    """
      SELECT
        COUNT(w) as total,
        t.id
      FROM
        (SELECT * FROM teams where challenge_id = #{challenge.id}) t
      LEFT JOIN
        team_memberships tm
      ON
        t.id = tm.team_id
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge.id}) w
      ON
        w.gym_rats_user_id = tm.account_id
      GROUP BY
        t.id
      HAVING
        COUNT(tm) > 0
      ORDER BY
        total DESC
      LIMIT 1
    """
  end

  defp score_for_team(team_id, challenge) do
    """
      SELECT
        SUM(COALESCE(CAST(w.#{challenge.score_by} as float), 0)) as total
      FROM
        (SELECT * FROM teams where id = #{team_id}) t
      LEFT JOIN
        team_memberships tm
      ON
        t.id = tm.team_id
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge.id}) w
      ON
        w.gym_rats_user_id = tm.account_id
    """
  end

  defp workouts_for_team(team_id, challenge) do
    """
      SELECT
        COUNT(w) as total
      FROM
        (SELECT * FROM teams where id = #{team_id}) t
      LEFT JOIN
        team_memberships tm
      ON
        t.id = tm.team_id
      LEFT JOIN
        (SELECT * FROM workouts WHERE challenge_id = #{challenge.id}) w
      ON
        w.gym_rats_user_id = tm.account_id
    """
  end
end
