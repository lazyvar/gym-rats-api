defmodule GymRatsWeb.Challenge.MemberController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.AccountView
  alias GymRats.Model.Account
  alias GymRats.Repo

  import Ecto.Query

  def index(conn, %{"challenge_id" => challenge_id}, _account_id) do
    challenge_id = String.to_integer(challenge_id)

    members =
      Account
      |> join(:left, [a], c in assoc(a, :memberships))
      |> where([a, m], a.id == m.gym_rats_user_id and m.challenge_id == ^challenge_id)
      |> Repo.all()

    success(conn, AccountView.default(members))
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id.")
end
