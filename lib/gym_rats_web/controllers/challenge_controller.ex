defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Challenge
  alias GymRats.Model.Membership
  alias GymRats.Query.ChallengeQuery

  import Ecto.Query
  import Logger

  def index(conn, %{"filter" => filter}, account_id) do
    challenge_query = case filter do
      "all" -> &ChallengeQuery.all/1
      "active" -> &ChallengeQuery.active/1
      "complete" -> &ChallengeQuery.complete/1
      "upcoming" -> &ChallengeQuery.upcoming/1
      _ -> nil
    end

    challenges = case challenge_query do
      nil -> []
      _ -> Challenge
        |> join(:left, [c], m in assoc(c, :memberships))
        |> where([_, m], m.gym_rats_user_id == ^account_id)
        |> challenge_query.()
        |> Repo.all
    end

    success(conn, challenges)
  end

  def index(conn, _params, account_id) do
    index(conn, %{"filter" => "all"}, account_id)
  end

  def create(conn, params, account_id) do
    changeset = Challenge.new_changeset(params)

    case Repo.insert(changeset) do
      {:ok, challenge} -> 
        membership = %Membership{} |> Membership.changeset(%{challenge_id: challenge.id, gym_rats_user_id: account_id, owner: true}) |> Repo.insert

        case membership do
          {:ok, membership} -> success(conn, challenge)
          {:error, m} -> Logger.info inspect(m)
           failure(conn, "Uh oh")
        end
       {:error, _} -> failure(conn, "Uh oh")
    end
  end

  def update(conn, params, account)
end