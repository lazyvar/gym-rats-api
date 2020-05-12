defmodule GymRatsWeb.DeviceControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "index/3" do
    test "fetches workouts for a challenge 40 at a time" do
      account = insert(:account) |> Account.put_token()
      params = [token: "<device_token>"]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/devices",
          params
        )

      assert %{
               "status" => "success"
             } = json_response(conn, 200)
    end
  end
end
