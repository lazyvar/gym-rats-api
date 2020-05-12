defmodule GymRatsWeb.Challenge.WorkoutControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "index/3" do
    test "fetches workouts for a challenge 40 at a time" do
      account = insert(:account) |> Account.put_token()
      account2 = insert(:account) |> Account.put_token()

      c1 = insert(:active_challenge, %{})

      insert(:membership, account: account, challenge: c1)
      insert(:membership, account: account2, challenge: c1)

      workout = insert(:workout, account: account, challenge: c1)
      workout2 = insert(:workout, account: account, challenge: c1)
      workout3 = insert(:workout, account: account, challenge: c1)
      workout4 = insert(:workout, account: account2, challenge: c1)
      workout5 = insert(:workout, account: account2, challenge: c1)
      workout6 = insert(:workout, account: account2, challenge: c1)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/#{c1.id}/workouts?page=0"
        )

      assert %{"status" => "success"} = json_response(conn, 200)
      response = json_response(conn, 200)
      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == workout.id end)
      assert data |> Enum.any?(fn c -> c["id"] == workout2.id end)
      assert data |> Enum.any?(fn c -> c["id"] == workout3.id end)
      assert data |> Enum.any?(fn c -> c["id"] == workout4.id end)
      assert data |> Enum.any?(fn c -> c["id"] == workout5.id end)
      assert data |> Enum.any?(fn c -> c["id"] == workout6.id end)
    end
  end
end
