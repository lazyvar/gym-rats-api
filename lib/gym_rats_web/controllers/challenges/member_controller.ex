defmodule GymRatsWeb.Challenge.MemberController do
  use GymRatsWeb, :protected_controller

  alias GymRats.Model.Membership
  alias GymRats.Model.Account
  alias GymRats.Repo

  import Ecto.Query
  
  def index(conn, %{"challenge_id" => challenge_id}, account_id) do
    members = Membership 
    |> where([m], m.challenge_id == ^challenge_id) 
    |> preload(:account) 
    |> Repo.all 
    |> Enum.map(fn m -> m.account |> Map.put(:token, nil) end)
    
    success(conn, members)
  end

  def index(conn, _params, _account_id), do: failure(conn, "Missing challenge id.")
end
