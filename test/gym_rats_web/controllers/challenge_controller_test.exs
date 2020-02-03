defmodule GymRatsWeb.Open.ChallengeControllerTests do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.Account
  alias GymRats.Model.Membership
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query
  
  @endpoint GymRatsWeb.Endpoint
  
  describe "create/3" do
    test "Creates and responds with the newly created user if attributes are valid" do
      params = [start_date: "2020-01-23T13:27:32Z", end_date: "2020-01-29T12:47:00Z", name: "Challenge", profile_picture_url: "k", time_zone: "PST"]
      account = insert(:account) |> Account.put_token
      conn = post(build_conn() |> put_req_header("authorization", account.token), "/challenges", params)

      assert %{
        "status" => "success",
        "data" => %{
          "start_date" => "2020-01-23T13:27:32Z",
          "name" => "Challenge",
          "profile_picture_url" => "k"
        }
      } = json_response(conn, 200)

      account = Account |> preload(:challenges) |> Repo.get(account.id)
      challenge = account.challenges |> List.first
      membership = Membership |> where([m], m.challenge_id == ^challenge.id and m.gym_rats_user_id == ^account.id) |> Repo.one
      assert membership.owner
    end

    test "Returns an error if name missing" do
      params = [start_date: "2020-01-23T13:27:32Z", end_date: "2020-01-29T12:47:00Z", profile_picture_url: "k", time_zone: "PST"]
      account = insert(:account) |> Account.put_token
      conn = post(build_conn() |> put_req_header("authorization", account.token), "/challenges", params)

      assert %{
        "status" => "failure",
        "error" => "Name can't be blank"
      } = json_response(conn, 422)
    end

    test "Returns an error if start_date missing" do
      params = [end_date: "2020-01-29T12:47:00Z", name: "Challenge", profile_picture_url: "k", time_zone: "PST"]
      account = insert(:account) |> Account.put_token
      conn = post(build_conn() |> put_req_header("authorization", account.token), "/challenges", params)

      assert %{
        "status" => "failure",
        "error" => "Start date can't be blank"
      } = json_response(conn, 422)
    end

    test "Returns an error if end_date missing" do
      params = [start_date: "2020-01-23T13:27:32Z", name: "Challenge", profile_picture_url: "k", time_zone: "PST"]
      account = insert(:account) |> Account.put_token
      conn = post(build_conn() |> put_req_header("authorization", account.token), "/challenges", params)

      assert %{
        "status" => "failure",
        "error" => "End date can't be blank"
      } = json_response(conn, 422)
    end
  end

  describe "index/3" do
    test "Returns all the challenges if no filter provided" do
      account = insert(:account) |> Account.put_token
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)
        
      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)
  
      conn = get(build_conn() |> put_req_header("authorization", account.token), "/challenges")
      response = json_response(conn, 200)
      
      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == upcoming_challenge.id end)
      assert data |> Enum.any?(fn c -> c["id"] == active_challenge.id end)
      assert data |> Enum.any?(fn c -> c["id"] == complete_challenge.id end)
    end

    test "Returns active challenges" do
      account = insert(:account) |> Account.put_token
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)
      
      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn = get(build_conn() |> put_req_header("authorization", account.token), "/challenges?filter=active")
      response = json_response(conn, 200)
      
      data = response["data"]

      assert is_list(data)
      assert length(data) == 1
      assert data |> Enum.any?(fn c -> c["id"] == active_challenge.id end)
    end

    test "Returns complete challenges" do
      account = insert(:account) |> Account.put_token
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)
      
      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn = get(build_conn() |> put_req_header("authorization", account.token), "/challenges?filter=complete")
      response = json_response(conn, 200)
      
      data = response["data"]

      assert is_list(data)
      assert length(data) == 1
      assert data |> Enum.any?(fn c -> c["id"] == complete_challenge.id end)
    end

    test "Returns upcoming challenges" do
      account = insert(:account) |> Account.put_token
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)
      
      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn = get(build_conn() |> put_req_header("authorization", account.token), "/challenges?filter=upcoming")
      response = json_response(conn, 200)
      
      data = response["data"]

      assert is_list(data)
      assert length(data) == 1
      assert data |> Enum.any?(fn c -> c["id"] == upcoming_challenge.id end)
    end
  end
end
