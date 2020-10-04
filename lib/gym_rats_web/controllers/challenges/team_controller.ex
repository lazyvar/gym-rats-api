defmodule GymRatsWeb.Challenge.TeamController do
  use GymRatsWeb, :protected_controller

  alias GymRatsWeb.TeamView
  alias GymRats.Model.{Membership, Team}
  alias GymRats.Repo

  import Ecto.Query

  def index(conn, %{"challenge_id" => challenge_id}, account_id) do
    challenge_id = String.to_integer(challenge_id)

    membership =
      Membership
      |> where(
        [m],
        m.gym_rats_user_id == ^account_id and m.challenge_id == ^challenge_id
      )
      |> Repo.one()

    case membership do
      nil ->
        failure(conn, "You are not a member of that challenge.")

      _ ->
        teams =
          Team
          |> join(:left, [t], c in assoc(t, :challenge))
          |> where([t, c], t.challenge_id == ^challenge_id)
          |> order_by(desc: :id)
          |> preload(:members)
          |> Repo.all()

        success(conn, TeamView.with_members(teams))
    end
  end

  def index(conn, _params, _account_id), do: failure(conn, "Invalid format.")
end
