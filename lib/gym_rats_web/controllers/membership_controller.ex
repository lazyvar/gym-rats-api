defmodule GymRatsWeb.MembershipController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Challenge, Membership, TeamMembership}
  alias GymRatsWeb.ChallengeView

  import Ecto.Query

  def create(conn, %{"code" => code}, account_id) do
    challenge = Challenge |> where([c], c.code == ^code) |> Repo.one()

    case challenge do
      nil ->
        failure(conn, "A challenge does not exist with that code.")

      _ ->
        membership =
          Membership
          |> where([m], m.challenge_id == ^challenge.id and m.gym_rats_user_id == ^account_id)
          |> Repo.one()

        case membership == nil do
          false ->
            success(conn, ChallengeView.default(challenge))

          true ->
            membership =
              %Membership{}
              |> Membership.changeset(%{
                challenge_id: challenge.id,
                gym_rats_user_id: account_id,
                owner: false
              })
              |> Repo.insert()

            case membership do
              {:ok, _} -> success(conn, ChallengeView.default(challenge))
              {:error, membership} -> failure(conn, membership)
            end
        end
    end
  end

  def create(conn, _params, _account_id), do: failure(conn, "Code missing.")

  def show(conn, %{"id" => challenge_id}, account_id) do
    membership =
      Membership
      |> where([m], m.challenge_id == ^challenge_id and m.gym_rats_user_id == ^account_id)
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "Membership does not exist.")

      _ ->
        success(conn, %{owner: membership.owner})
    end
  end

  def delete(conn, %{"id" => challenge_id}, account_id) do
    challenge = Challenge |> Repo.get(challenge_id)

    membership =
      Membership
      |> where([m], m.challenge_id == ^challenge_id and m.gym_rats_user_id == ^account_id)
      |> Repo.one()

    team_memberships =
      TeamMembership
      |> join(:left, [tm], t in assoc(tm, :team))
      |> where(
        [tm, t],
        tm.account_id == ^account_id and t.challenge_id == ^challenge.id
      )
      |> Repo.all()

    if team_memberships != nil do
      Enum.each(team_memberships, fn tm ->
        tm |> Repo.delete!()
      end)
    end

    if membership != nil do
      membership |> Repo.delete!()
    end

    success(conn, ChallengeView.default(challenge))
  end

  def delete(conn, _params, _account_id), do: failure(conn, "Challenge id missing.")
end
