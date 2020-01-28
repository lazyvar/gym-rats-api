defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Challenge
  alias GymRats.Repo.ChallengeRepo

  import Logger

  def index(conn, %{"filter" => filter}, account) do
    challenges = case filter do
      "all" -> ChallengeRepo.all
      "active" -> ChallengeRepo.active
      "complete" -> ChallengeRepo.complete
      "upcoming" -> ChallengeRepo.upcoming
      _ -> []
    end
    
    Logger.info inspect(account)

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