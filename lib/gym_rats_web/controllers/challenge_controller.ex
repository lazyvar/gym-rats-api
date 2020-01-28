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

  def index(conn, %{"filter" => filter}, account_id) do
    challenge_query = case filter do
      "all" -> &ChallengeQuery.all/1
      "active" -> &ChallengeQuery.active/1
      "complete" -> &ChallengeQuery.complete/1
      "upcoming" -> &ChallengeQuery.upcoming/1
      _ -> nil
    end

    query = from c in Challenge, join: m in Membership, on: m.challenge_id == c.id, where: m.gym_rats_user_id == ^account_id

    challenges = case challenge_query do
      nil -> []
      _ -> query |> challenge_query.() |> Repo.all
    end

    success(conn, challenges)
  end

  def index(conn, _params, account_id) do
    index(conn, %{"filter" => "all"}, account_id)
  end

  def create(conn, params, account_id) do
    changeset = Challenge.new_changeset(params)

    case Repo.insert(changeset) do
      {:ok, challenge} -> success(conn, challenge)
      {:error, _} -> failure(conn, "Uh oh")
    end
  end
end