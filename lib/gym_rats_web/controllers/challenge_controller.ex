defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :controller
  
  alias GymRats.Model.Challenge

  def index(conn, _params) do
    success(conn, Repo.all(Challenge))
  end
end