defmodule GymRatsWeb.ChallengeController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.{Challenge, Membership}
  alias GymRats.Query.ChallengeQuery
  alias GymRatsWeb.ChallengeView

  import Ecto.Query

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

    success(conn, ChallengeView.default(challenges))
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
          {:ok, _} -> success(conn, ChallengeView.default(challenge))
          {:error, membership} -> failure(conn, membership)
        end
       {:error, challenge} -> failure(conn, challenge)
    end
  end

  def update(conn, %{"id" => id} = params, account_id) do
    id = String.to_integer(id)
    challenge = Challenge |> Repo.get(id)

    case challenge do
      nil -> failure(conn, "This challenge does not exist.")
      _ ->
        membership = Membership |> where([m], m.gym_rats_user_id == ^account_id and m.challenge_id == ^id) |> Repo.one

        case membership do
          nil -> failure(conn, "That challenge does not exist.")
          _ -> 
            if membership.owner do
              illegal_params = ~w(id created_at updated_at code time_zone)
              params = params |> Map.drop(illegal_params)
              challenge = challenge |> Challenge.changeset(params) |> Repo.update

              case challenge do
                {:ok, challenge} -> success(conn, ChallengeView.default(challenge))
                {:error, _} -> failure(conn, "Something went wrong.")
              end
            else
              failure(conn, "You are not authorized edit a challenge. Ask the challenge creator to do so.")
            end
        end
    end
  end
end