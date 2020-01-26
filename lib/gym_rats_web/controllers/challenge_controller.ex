defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :controller
  alias GymRats.Model.Challenge

  def index(conn, _params) do
    challenges = Repo.all(Challenge)

    json(conn, %{data: challenges})
  end
end