defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :controller

  alias GymRats.Model.Challenge
  alias GymRats.Repo.ChallengeRepo

  def index(conn, %{"filter" => filter}) do
    challenges = case filter do
      "all" -> ChallengeRepo.all
      "active" -> ChallengeRepo.active
      "complete" -> ChallengeRepo.complete
      "upcoming" -> ChallengeRepo.upcoming
      _ -> []
    end
    
    success(conn, challenges)
  end

  def index(conn, _params) do
    index(conn, %{"filter" => "all"})
  end

  def create(conn, params) do
    changeset = Challenge.new_changeset(params)

    case Repo.insert(changeset) do
      {:ok, challenge} -> success(conn, challenge)
      {:error, _} -> failure(conn, "Uh oh")
    end
  end
end