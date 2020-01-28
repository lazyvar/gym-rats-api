defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Challenge
  alias GymRats.Model.Account
  alias GymRats.Model.Membership
  alias GymRats.Repo.ChallengeRepo
  alias GymRats.Repo.AccountRepo
  alias GymRats.Query.ChallengeQuery

  import Logger
  import Ecto.Query

  def index(conn, %{"filter" => filter}, account) do
    challenge_query = case filter do
      "all" -> ChallengeQuery.all
      "active" -> ChallengeQuery.active
      "complete" -> ChallengeQuery.complete
      "upcoming" -> ChallengeQuery.upcoming
      _ -> nil
    end

    challenges = case challenge_query do
      nil -> []
      _ -> account 
        |> Repo.preload(challenges: from(challenge_query))
        |> Map.get(:challenges)
    end

    success(conn, challenges)
  end

  def index(conn, _params, account) do
    index(conn, %{"filter" => "all"}, account)
  end

  def create(conn, params, account) do
    changeset = Challenge.new_changeset(params)

    case Repo.insert(changeset) do
      {:ok, challenge} -> success(conn, challenge)
      {:error, _} -> failure(conn, "Uh oh")
    end
  end
end