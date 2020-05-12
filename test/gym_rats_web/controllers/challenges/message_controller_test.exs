defmodule GymRatsWeb.Challenge.MessageControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "index/3" do
    test "fetches messages for a challenge 40 at a time" do
      account = insert(:account) |> Account.put_token()
      account2 = insert(:account) |> Account.put_token()

      c1 = insert(:active_challenge, %{})

      insert(:membership, account: account, challenge: c1)
      insert(:membership, account: account2, challenge: c1)

      message = insert(:message, account: account, challenge: c1)
      message1 = insert(:message, account: account, challenge: c1)
      message2 = insert(:message, account: account, challenge: c1)
      message3 = insert(:message, account: account2, challenge: c1)
      message4 = insert(:message, account: account2, challenge: c1)
      message5 = insert(:message, account: account2, challenge: c1)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/#{c1.id}/messages?page=0"
        )

      assert %{"status" => "success"} = json_response(conn, 200)
      response = json_response(conn, 200)
      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == message.id end)
      assert data |> Enum.any?(fn c -> c["id"] == message1.id end)
      assert data |> Enum.any?(fn c -> c["id"] == message2.id end)
      assert data |> Enum.any?(fn c -> c["id"] == message3.id end)
      assert data |> Enum.any?(fn c -> c["id"] == message4.id end)
      assert data |> Enum.any?(fn c -> c["id"] == message5.id end)
    end
  end
end
