defmodule GymRatsWeb.Open.TokenControllerTest do
  use GymRatsWeb.ConnCase

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "create/2" do
    test "Returns the user and a token if credentials match" do
      account = insert(:account)
      conn = post(build_conn(), "/tokens", email: account.email, password: "password")
      response = json_response(conn, 200)
      data = response["data"]

      assert response["status"] == "success"
      assert data["email"] == account.email
      assert data["full_name"] == account.full_name
      assert data["profile_picture_url"] == account.profile_picture_url
      assert data["id"] == account.id
    end

    test "Returns error if account does not exist" do
      account = insert(:account)
      conn = post(build_conn(), "/tokens", email: account.email, password: "password_wrong")

      assert %{
               "status" => "failure",
               "error" => "That email and password combination did not work"
             } = json_response(conn, 422)
    end

    test "Returns error if password does not match" do
      conn = post(build_conn(), "/tokens", email: "does@not.exist", password: "password")

      assert %{
               "status" => "failure",
               "error" => "That email and password combination did not work"
             } = json_response(conn, 422)
    end
  end
end
