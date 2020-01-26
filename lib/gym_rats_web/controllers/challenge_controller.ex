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

    if changeset.valid? do
      success(conn, Repo.insert!(changeset))
    else
      failure(conn, "Uh oh")
    end
  end
end