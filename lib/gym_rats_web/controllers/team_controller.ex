defmodule GymRatsWeb.TeamController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Membership, Team, TeamMembership}
  alias GymRatsWeb.TeamView

  import Ecto.Query

  def create(conn, %{"challenge_id" => challenge_id} = params, account_id) do
    membership =
      Membership
      |> where([m], m.gym_rats_user_id == ^account_id and m.challenge_id == ^challenge_id)
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "You are not a member of that challenge.")

      _ ->
        changeset = %Team{} |> Team.changeset(params)

        case Repo.insert(changeset) do
          {:ok, team} ->
            team_memberships =
              TeamMembership
              |> join(:left, [tm], t in assoc(tm, :team))
              |> where(
                [tm, t],
                tm.account_id == ^account_id and t.challenge_id == ^challenge_id
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
              {:ok, _} ->
                team = Team |> Repo.get!(team.id)
                success(conn, TeamView.default(team))

              {:error, team_membership} ->
                failure(conn, team_membership)
            end

          {:error, team} ->
            failure(conn, team)
        end
    end
  end

  def create(conn, _params, _account_id), do: failure(conn, "Invalid format")

  def update(conn, %{"id" => id} = params, account_id) do
    id = String.to_integer(id)
    team = Team |> Repo.get(id)

    case team do
      nil ->
        failure(conn, "This team does not exist.")

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

            team_membership =
              TeamMembership
              |> where([m], m.account_id == ^account_id and m.team_id == ^id)
              |> Repo.one()

            case team_membership do
              nil ->
                failure(conn, "You are not a member of that team.")

              _ ->
                illegal_params = ~w(id challenge_id inserted_at updated_at)
                params = params |> Map.drop(illegal_params)
                team = team |> Team.changeset(params) |> Repo.update()

                case team do
                  {:ok, team} -> success(conn, TeamView.default(team))
                  {:error, team} -> failure(conn, team)
                end
            end
        end
    end
  end

  def update(conn, _params, _account_id), do: failure(conn, "Invalid format")
end
