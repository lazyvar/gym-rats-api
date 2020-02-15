defmodule GymRatsWeb.MembershipControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account, Challenge, Membership}
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query

  @endpoint GymRatsWeb.Endpoint

  describe "create/3" do
    test "joins a challenge" do
      account = insert(:account) |> Account.put_token()
      challenge = insert(:challenge, %{code: "123456"})

      params = [code: "123456"]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships",
          params
        )

      assert %{
               "data" => %{
                 "code" => "123456",
                 "name" => "Challenge accepted!",
                 "profile_picture_url" => "i.reddit.com/woop"
               },
               "status" => "success"
             } = json_response(conn, 200)

      membership =
        Membership
        |> where([m], m.challenge_id == ^challenge.id and m.gym_rats_user_id == ^account.id)
        |> Repo.one()

      assert !membership.owner
    end

    test "handles missing code" do
      account = insert(:account) |> Account.put_token()
      challenge = insert(:challenge, %{code: "123456"})

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships"
        )

      assert %{"error" => "Code missing.", "status" => "failure"} = json_response(conn, 422)
    end

    test "handles bad code" do
      account = insert(:account) |> Account.put_token()
      challenge = insert(:challenge, %{code: "abc"})
      params = [code: "666"]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships",
          params
        )

      assert %{"error" => "A challenge does not exist with that code.", "status" => "failure"} =
               json_response(conn, 422)
    end

    test "cant join twice" do
      account = insert(:account) |> Account.put_token()
      challenge = insert(:challenge, %{code: "123456"})

      params = [code: "123456"]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships",
          params
        )

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships",
          params
        )

      assert %{"error" => "You are already a part of this challenge.", "status" => "failure"} =
               json_response(conn, 422)
    end
  end

  describe "delete/3" do
    test "leave challenge" do
      account = insert(:account) |> Account.put_token()
      challenge = insert(:challenge)

      insert(:membership, account: account, challenge: challenge)

      conn =
        delete(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships/#{challenge.id}"
        )

      assert %{
               "data" => %{
                 "name" => "Challenge accepted!",
                 "profile_picture_url" => "i.reddit.com/woop"
               },
               "status" => "success"
             } = json_response(conn, 200)

      conn =
        delete(
          build_conn() |> put_req_header("authorization", account.token),
          "/memberships/#{challenge.id}"
        )

      assert %{"error" => "Membership does not exist.", "status" => "failure"} =
               json_response(conn, 422)
    end
  end
end
