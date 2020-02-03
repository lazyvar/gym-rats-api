defmodule GymRatsWeb.Open.ChallengeControllerTests do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.Account

  import GymRats.Factory
  
  @endpoint GymRatsWeb.Endpoint
  
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
