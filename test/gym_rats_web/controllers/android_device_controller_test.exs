defmodule GymRatsWeb.AndroidDeviceControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "create/3" do
    test "saves device" do
      account = insert(:account) |> Account.put_token()
      params = [token: "<device_token>"]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/android_devices",
          params
        )

      assert %{
               "status" => "success"
             } = json_response(conn, 200)
    end
  end
end
