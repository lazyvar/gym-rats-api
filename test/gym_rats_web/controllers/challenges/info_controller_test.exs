defmodule GymRatsWeb.Challenge.InfoControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account, Challenge}
  alias GymRats.Repo

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "info/3" do
    test "gets basic info" do
      account1 = insert(:account) |> Account.put_token()
      account2 = insert(:account) |> Account.put_token()
      account3 = insert(:account) |> Account.put_token()

      c1 = insert(:active_challenge, %{})

      insert(:membership, account: account1, challenge: c1)
      insert(:membership, account: account2, challenge: c1)
      insert(:membership, account: account3, challenge: c1)

      insert(:workout, account: account1, challenge: c1)
      insert(:workout, account: account2, challenge: c1)
      insert(:workout, account: account3, challenge: c1)
      insert(:workout, account: account1, challenge: c1)
      insert(:workout, account: account2, challenge: c1)
      insert(:workout, account: account3, challenge: c1)
      insert(:workout, account: account1, challenge: c1)
      insert(:workout, account: account2, challenge: c1)
      insert(:workout, account: account3, challenge: c1)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account1.token),
          "/challenges/#{c1.id}/info"
        )

      assert %{
               "status" => "success",
               "data" => %{
                 "member_count" => 3,
                 "workout_count" => 9,
                 "leader_score" => "3",
                 "current_account_score" => "3"
               }
             } = json_response(conn, 200)

      c1 = c1 |> Challenge.changeset(%{"score_by" => "duration"}) |> Repo.update!()

      insert(:workout, account: account1, challenge: c1, duration: "33")
      insert(:workout, account: account2, challenge: c1, duration: "10")
      insert(:workout, account: account3, challenge: c1, duration: "20")
      insert(:workout, account: account2, challenge: c1, duration: "10")
      insert(:workout, account: account3, challenge: c1, duration: "20")

      conn =
        get(
          build_conn() |> put_req_header("authorization", account1.token),
          "/challenges/#{c1.id}/info"
        )

      assert %{
               "status" => "success",
               "data" => %{
                 "member_count" => 3,
                 "workout_count" => 14,
                 "leader_score" => "310",
                 "current_account_score" => "303"
               }
             } = json_response(conn, 200)

      c2 = insert(:active_challenge, %{})
      insert(:membership, account: account1, challenge: c2)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account1.token),
          "/challenges/#{c2.id}/info"
        )

      assert %{
               "status" => "success",
               "data" => %{
                 "member_count" => 1,
                 "workout_count" => 0,
                 "leader_score" => "-",
                 "current_account_score" => "-"
               }
             } = json_response(conn, 200)
    end
  end
end
