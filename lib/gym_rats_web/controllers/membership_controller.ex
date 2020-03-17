defmodule GymRatsWeb.MembershipController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Challenge, Membership}
  alias GymRatsWeb.ChallengeView

  import Ecto.Query

  def create(conn, %{"code" => code}, account_id) do
    code = code |> String.upcase()
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
            failure(conn, "You are already a part of this challenge.")

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

  def delete(conn, %{"id" => challenge_id}, account_id) do
    membership =
      Membership
      |> where([m], m.challenge_id == ^challenge_id and m.gym_rats_user_id == ^account_id)
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "Membership does not exist.")

      _ ->
        membership |> Repo.delete!()
        challenge = Challenge |> Repo.get(membership.challenge_id)

        success(conn, ChallengeView.default(challenge))
    end
  end

  def delete(conn, _params, _account_id), do: failure(conn, "Challenge id missing.")
end
