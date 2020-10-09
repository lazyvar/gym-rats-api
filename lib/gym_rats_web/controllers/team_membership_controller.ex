defmodule GymRatsWeb.TeamMembershipController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Team, TeamMembership, Membership}
  alias GymRatsWeb.TeamView

  import Ecto.Query

  def create(conn, %{"team_id" => team_id}, account_id) do
    team = Team |> Repo.get(team_id)

    case team do
      nil ->
        failure(conn, "That team does not exist.")

      _ ->
        membership =
          Membership
          |> where(
            [m],
            m.gym_rats_user_id == ^account_id and m.challenge_id == ^team.challenge_id
          )
          |> Repo.one()

        case membership do
          nil ->
            failure(conn, "You are not a member of that challenge.")

          _ ->
            team_memberships =
              TeamMembership
              |> join(:left, [tm], t in assoc(tm, :team))
              |> where(
                [tm, t],
                tm.account_id == ^account_id and t.challenge_id == ^team.challenge_id
              )
              |> Repo.all()

            if team_memberships != nil do
              Enum.each(team_memberships, fn tm ->
                tm |> Repo.delete!()
              end)
            end

            team_membership =
              %TeamMembership{}
              |> TeamMembership.changeset(%{
                team_id: team.id,
                account_id: account_id
              })
              |> Repo.insert()

            case team_membership do
              {:ok, _} -> success(conn, TeamView.default(team))
              {:error, team_membership} -> failure(conn, team_membership)
            end
        end
    end
  end

  def create(conn, _params, _account_id), do: failure(conn, "Invalid format.")

  def show(conn, %{"id" => team_id}, account_id) do
    team_membership =
      TeamMembership
      |> where([tm], tm.team_id == ^team_id and tm.account_id == ^account_id)
      |> Repo.one()

    case team_membership do
      nil ->
        failure(conn, "Team membership does not exist.")

      _ ->
        success(conn, %{})
    end
  end

  def delete(conn, %{"id" => team_id}, account_id) do
    team_membership =
      TeamMembership
      |> where([m], m.team_id == ^team_id and m.account_id == ^account_id)
      |> Repo.one()

    case team_membership do
      nil ->
        failure(conn, "Mission success.")

      _ ->
        team_membership |> Repo.delete!()
        team = Team |> Repo.get(team_id)

        success(conn, TeamView.default(team))
    end
  end

  def delete(conn, _params, _account_id), do: failure(conn, "Invalid format.")
end
