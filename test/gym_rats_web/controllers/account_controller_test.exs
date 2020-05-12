defmodule GymRatsWeb.AccountControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "update_self/3" do
    test "account properties get updated" do
      account = insert(:account) |> Account.put_token()

      updates = [
        full_name: "Joe",
        profile_picture_url: "https://google.com",
        email: "new@email.co"
      ]

      conn =
        put(
          build_conn() |> put_req_header("authorization", account.token),
          "/accounts/self",
          updates
        )

      assert %{
               "status" => "success",
               "data" => %{
                 "email" => "new@email.co",
                 "full_name" => "Joe",
                 "profile_picture_url" => "https://google.com"
               }
             } = json_response(conn, 200)
    end

    test "illegal params do not get updated" do
      account = insert(:account) |> Account.put_token()

      updates = [
        password_digest: 123,
        reset_password_token: 123,
        created_at: "new@email.co"
      ]

      conn =
        put(
          build_conn() |> put_req_header("authorization", account.token),
          "/accounts/self",
          updates
        )

      assert %{} = json_response(conn, 200)
    end

    test "error messages shown on invalid changeset" do
      account1 = insert(:account) |> Account.put_token()
      account2 = insert(:account) |> Account.put_token()

      updates = [email: account2.email]

      conn =
        put(
          build_conn() |> put_req_header("authorization", account1.token),
          "/accounts/self",
          updates
        )

      assert %{
               "status" => "failure",
               "error" => "Email has already been taken"
             } = json_response(conn, 422)
    end
  end
end
