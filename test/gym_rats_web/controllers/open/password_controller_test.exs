defmodule GymRatsWeb.Open.PasswordControllerTest do
  use GymRatsWeb.ConnCase
  use Bamboo.Test

  alias GymRats.Model.{Account}
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query

  @endpoint GymRatsWeb.Endpoint

  describe "create/2" do
    test "Account with email does not exist." do
      conn = post(build_conn(), "/passwords", email: "does@not.exist")

      assert %{
               "status" => "failure",
               "error" => "An account with that email does not exist."
             } = json_response(conn, 422)
    end

    test "Sends email with reset password link." do
      account = insert(:account)
      conn = post(build_conn(), "/passwords", email: account.email)
      account = Account |> Repo.get(account.id)
      expected_email = GymRats.Mail.ResetPassword.email(account, account.reset_password_token)

      assert %{
               "status" => "success",
               "data" => %{}
             } = json_response(conn, 200)

      assert_delivered_email(expected_email)
    end

    test "Updates token and experation on account." do
      account = insert(:account)
      conn = post(build_conn(), "/passwords", email: account.email)
      account = Account |> Repo.get(account.id)

      assert %{
               "status" => "success",
               "data" => %{}
             } = json_response(conn, 200)

      assert account.reset_password_token != nil
      assert account.reset_password_token_expiration != nil
    end
  end

  describe "update/2" do
    test "Account not found for token" do
      conn = put(build_conn(), "/passwords/bad_token", password: "new_password")

      assert %{
               "status" => "failure",
               "error" => "Token expired."
             } = json_response(conn, 422)
    end

    test "Token has expired" do
      account = insert(:account)
      conn = post(build_conn(), "/passwords", email: account.email)
      update = %{reset_password_token_expiration: DateTime.utc_now()}
      account = account |> Account.changeset(update) |> Repo.update!()
      account = Account |> Repo.get(account.id)

      conn =
        put(build_conn(), "/passwords/#{account.reset_password_token}", password: "new_password")

      assert %{
               "status" => "failure",
               "error" => "Token expired."
             } = json_response(conn, 422)
    end

    test "Token is valid" do
      account = insert(:account)
      conn = post(build_conn(), "/passwords", email: account.email)
      account = Account |> Repo.get(account.id)

      conn =
        put(build_conn(), "/passwords/#{account.reset_password_token}", password: "new_password")

      assert %{
               "status" => "success",
               "data" => %{}
             } = json_response(conn, 200)

      conn = post(build_conn(), "/tokens", email: account.email, password: "new_password")
      response = json_response(conn, 200)
      data = response["data"]

      assert response["status"] == "success"
      assert data["email"] == account.email
      assert data["full_name"] == account.full_name
      assert data["profile_picture_url"] == account.profile_picture_url
      assert data["id"] == account.id
    end
  end
end
