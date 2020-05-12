defmodule GymRatsWeb.Challenge.MemberControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "index/3" do
    test "fetches all members for a challenge" do
      account1 = insert(:account) |> Account.put_token()
      account2 = insert(:account) |> Account.put_token()
      account3 = insert(:account) |> Account.put_token()
      account4 = insert(:account) |> Account.put_token()

      c1 = insert(:active_challenge, %{})

      insert(:membership, account: account1, challenge: c1)
      insert(:membership, account: account2, challenge: c1)
      insert(:membership, account: account3, challenge: c1)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account1.token),
          "/challenges/#{c1.id}/members"
        )

      assert %{"status" => "success"} = json_response(conn, 200)
      response = json_response(conn, 200)
      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == account1.id end)
      assert data |> Enum.any?(fn c -> c["id"] == account2.id end)
      assert data |> Enum.any?(fn c -> c["id"] == account3.id end)
      assert !(data |> Enum.any?(fn c -> c["id"] == account4.id end))
    end
  end
end
