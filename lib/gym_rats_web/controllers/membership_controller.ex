defmodule GymRatsWeb.MembershipController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Challenge
  alias GymRats.Model.Membership
  
  import Ecto.Query

  def create(conn, params, account_id) do
    code = params["code"] |> String.upcase
    challenge = Challenge |> where([c], c.code == ^code) |> Repo.one

    case challenge do
      nil -> failure(conn, "A challenge does not exist with that code.")
      _ ->
        membership = Membership 
        |> where([m], m.challenge_id == ^challenge.id and m.gym_rats_user_id == ^account_id) 
        |> Repo.one
        
        case membership == nil do
          false -> failure(conn, "You are already a part of this challenge.")
          true -> 
            membership = Membership.join_changeset(challenge_id: challenge.id, account_id: account_id) |> Repo.insert
            case membership do
              {:ok, membership} -> success(conn, challenge)
              {:error, _} -> failure(conn, "Uh oh")
            end
      end
    end
  end

  def delete(conn, params, account_id) do

  end
end