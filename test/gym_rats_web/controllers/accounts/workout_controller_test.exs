defmodule GymRatsWeb.Account.WorkoutControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "index/3" do
    test "fetches all workouts for a user" do
      account = insert(:account) |> Account.put_token()

      c1 = insert(:active_challenge, %{})
      c2 = insert(:active_challenge, %{})
      c3 = insert(:complete_challenge, %{})
      c4 = insert(:upcoming_challenge, %{})

      insert(:membership, account: account, challenge: c1)
      insert(:membership, account: account, challenge: c2)
      insert(:membership, account: account, challenge: c3)
      insert(:membership, account: account, challenge: c4)

      w1 = insert(:workout, account: account, challenge: c1)
      w2 = insert(:workout, account: account, challenge: c2)
      w3 = insert(:workout, account: account, challenge: c3)
      w4 = insert(:workout, account: account, challenge: c4)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/accounts/#{account.id}/workouts"
        )

      assert %{"status" => "success"} = json_response(conn, 200)
      response = json_response(conn, 200)
      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == w1.id end)
      assert data |> Enum.any?(fn c -> c["id"] == w2.id end)
      assert data |> Enum.any?(fn c -> c["id"] == w3.id end)
      assert data |> Enum.any?(fn c -> c["id"] == w4.id end)
    end
  end
end
