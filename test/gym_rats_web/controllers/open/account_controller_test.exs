defmodule GymRatsWeb.Open.AccountControllerTest do
  use GymRatsWeb.ConnCase

  @endpoint GymRatsWeb.Endpoint
  
  describe "create/2" do
    test "Creates and responds with the newly created user if attributes are valid" do
      new_user = [full_name: "Mack", profile_picture_url: "https://google.com", email: "mack@dad.ie", password: "yikessss"]
      conn = post(build_conn(), "/accounts", new_user)

      assert %{
        "status" => "success",
        "data" => %{
          "email" => "mack@dad.ie",
          "full_name" => "Mack",
          "profile_picture_url" => "https://google.com"
        }
      } = json_response(conn, 200)
    end

    test "Returns an error if email missing" do
      new_user = [full_name: "Mack", profile_picture_url: "https://google.com", password: "yikessss"]
      conn = post(build_conn(), "/accounts", new_user)

      assert %{
        "status" => "failure",
        "error" => "Email can't be blank"
      } = json_response(conn, 422)
    end

    test "Returns an error if email taken" do
      new_user = [full_name: "Mack", profile_picture_url: "https://google.com", email: "mack@dad.ie", password: "yikessss"]
      conn = post(build_conn(), "/accounts", new_user)
      conn = post(build_conn(), "/accounts", new_user)

      assert %{
        "status" => "failure",
        "error" => "Email has already been taken"
      } = json_response(conn, 422)
    end

    test "Returns an error if password less than 6" do
      new_user = [full_name: "Mack", profile_picture_url: "https://google.com", email: "mack@dad.ie", password: "123"]
      conn = post(build_conn(), "/accounts", new_user)
      conn = post(build_conn(), "/accounts", new_user)

      assert %{
        "status" => "failure",
        "error" => "Password should be at least 6 character(s)"
      } = json_response(conn, 422)
    end
  end
end
