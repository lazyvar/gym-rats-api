defmodule GymRatsWeb.Challenge.ChatNotificationControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.Account

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "count/3" do
    test "returns the count of unseed chat notifications" do
      my_account = insert(:account) |> Account.put_token()
      some_account1 = insert(:account) |> Account.put_token()
      some_account2 = insert(:account) |> Account.put_token()

      challenge = insert(:challenge)
      message1 = insert(:message, account: some_account1, challenge: challenge)
      message2 = insert(:message, account: some_account2, challenge: challenge)
      message3 = insert(:message, account: some_account1, challenge: challenge)
      message4 = insert(:message, account: some_account2, challenge: challenge)
      message5 = insert(:message, account: some_account2, challenge: challenge)

      message6 = insert(:message, account: my_account, challenge: challenge)
      message7 = insert(:message, account: my_account, challenge: challenge)
      message8 = insert(:message, account: my_account, challenge: challenge)
      message9 = insert(:message, account: my_account, challenge: challenge)
      message10 = insert(:message, account: my_account, challenge: challenge)

      insert(:chat_notification, account: my_account, message: message1)
      insert(:chat_notification, account: my_account, message: message2)
      insert(:chat_notification, account: my_account, message: message3)
      insert(:chat_notification, account: my_account, message: message4)
      insert(:chat_notification, account: my_account, message: message5)

      insert(:chat_notification, account: some_account2, message: message6)
      insert(:chat_notification, account: some_account1, message: message7)
      insert(:chat_notification, account: some_account2, message: message8)
      insert(:chat_notification, account: some_account1, message: message9)
      insert(:chat_notification, account: some_account1, message: message10)

      conn =
        get(
          build_conn() |> put_req_header("authorization", my_account.token),
          "/challenges/#{challenge.id}/chat_notifications/count"
        )

      assert %{
               "data" => %{
                 "count" => 5
               },
               "status" => "success"
             } = json_response(conn, 200)
    end
  end

  describe "seen/3" do
    test "marks the chat notifications as seen" do
      my_account = insert(:account) |> Account.put_token()
      some_account1 = insert(:account) |> Account.put_token()
      some_account2 = insert(:account) |> Account.put_token()

      challenge = insert(:challenge)
      message1 = insert(:message, account: some_account1, challenge: challenge)
      message2 = insert(:message, account: some_account2, challenge: challenge)
      message3 = insert(:message, account: some_account1, challenge: challenge)
      message4 = insert(:message, account: some_account2, challenge: challenge)
      message5 = insert(:message, account: some_account2, challenge: challenge)

      message6 = insert(:message, account: my_account, challenge: challenge)
      message7 = insert(:message, account: my_account, challenge: challenge)
      message8 = insert(:message, account: my_account, challenge: challenge)
      message9 = insert(:message, account: my_account, challenge: challenge)
      message10 = insert(:message, account: my_account, challenge: challenge)

      insert(:chat_notification, account: my_account, message: message1)
      insert(:chat_notification, account: my_account, message: message2)
      insert(:chat_notification, account: my_account, message: message3)
      insert(:chat_notification, account: my_account, message: message4)
      insert(:chat_notification, account: my_account, message: message5)

      insert(:chat_notification, account: some_account2, message: message6)
      insert(:chat_notification, account: some_account1, message: message7)
      insert(:chat_notification, account: some_account2, message: message8)
      insert(:chat_notification, account: some_account1, message: message9)
      insert(:chat_notification, account: some_account1, message: message10)

      conn =
        post(
          build_conn() |> put_req_header("authorization", my_account.token),
          "/challenges/#{challenge.id}/chat_notifications/seen"
        )

      assert %{
               "data" => "👁️",
               "status" => "success"
             } = json_response(conn, 200)

      conn =
        get(
          build_conn() |> put_req_header("authorization", my_account.token),
          "/challenges/#{challenge.id}/chat_notifications/count"
        )

      assert %{
               "data" => %{
                 "count" => 0
               },
               "status" => "success"
             } = json_response(conn, 200)

      conn =
        get(
          build_conn() |> put_req_header("authorization", some_account2.token),
          "/challenges/#{challenge.id}/chat_notifications/count"
        )

      assert %{
               "data" => %{
                 "count" => 2
               },
               "status" => "success"
             } = json_response(conn, 200)

      conn =
        get(
          build_conn() |> put_req_header("authorization", some_account1.token),
          "/challenges/#{challenge.id}/chat_notifications/count"
        )

      assert %{
               "data" => %{
                 "count" => 3
               },
               "status" => "success"
             } = json_response(conn, 200)
    end
  end
end
