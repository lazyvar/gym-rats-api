defmodule GymRatsWeb.ChallengeControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account, Membership}
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query

  @endpoint GymRatsWeb.Endpoint

  describe "create/3" do
    test "Creates and responds with the newly created user if attributes are valid" do
      params = [
        start_date: "2020-01-23T13:27:32Z",
        end_date: "2020-01-29T12:47:00Z",
        name: "Challenge",
        profile_picture_url: "k",
        time_zone: "PST"
      ]

      account = insert(:account) |> Account.put_token()

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges",
          params
        )

      assert %{
               "status" => "success",
               "data" => %{
                 "start_date" => "2020-01-23T13:27:32.000000Z",
                 "name" => "Challenge",
                 "profile_picture_url" => "k"
               }
             } = json_response(conn, 200)

      account = Account |> preload(:challenges) |> Repo.get(account.id)
      challenge = account.challenges |> List.first()

      membership =
        Membership
        |> where([m], m.challenge_id == ^challenge.id and m.gym_rats_user_id == ^account.id)
        |> Repo.one()

      assert membership.owner
    end

    test "Returns an error if name missing" do
      params = [
        start_date: "2020-01-23T13:27:32Z",
        end_date: "2020-01-29T12:47:00Z",
        profile_picture_url: "k",
        time_zone: "PST"
      ]

      account = insert(:account) |> Account.put_token()

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges",
          params
        )

      assert %{
               "status" => "failure",
               "error" => "Name can't be blank"
             } = json_response(conn, 422)
    end

    test "Returns an error if start_date missing" do
      params = [
        end_date: "2020-01-29T12:47:00Z",
        name: "Challenge",
        profile_picture_url: "k",
        time_zone: "PST"
      ]

      account = insert(:account) |> Account.put_token()

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges",
          params
        )

      assert %{
               "status" => "failure",
               "error" => "Start date can't be blank"
             } = json_response(conn, 422)
    end

    test "Returns an error if end_date missing" do
      params = [
        start_date: "2020-01-23T13:27:32Z",
        name: "Challenge",
        profile_picture_url: "k",
        time_zone: "PST"
      ]

      account = insert(:account) |> Account.put_token()

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges",
          params
        )

      assert %{
               "status" => "failure",
               "error" => "End date can't be blank"
             } = json_response(conn, 422)
    end
  end

  describe "index/3" do
    test "find by code" do
      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges?code=#{upcoming_challenge.code}"
        )

      response = json_response(conn, 200)

      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == upcoming_challenge.id end)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges?code=123asda12"
        )

      assert %{
               "status" => "failure",
               "error" => "A challenge with that code does not exist."
             } = json_response(conn, 422)
    end

    test "Returns all the challenges if no filter provided" do
      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)

      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn = get(build_conn() |> put_req_header("authorization", account.token), "/challenges")
      response = json_response(conn, 200)

      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == upcoming_challenge.id end)
      assert data |> Enum.any?(fn c -> c["id"] == active_challenge.id end)
      assert data |> Enum.any?(fn c -> c["id"] == complete_challenge.id end)
    end

    test "Returns active challenges" do
      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)

      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges?filter=active"
        )

      response = json_response(conn, 200)

      data = response["data"]

      assert is_list(data)
      assert length(data) == 1
      assert data |> Enum.any?(fn c -> c["id"] == active_challenge.id end)
    end

    test "Returns complete challenges" do
      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)

      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges?filter=complete"
        )

      response = json_response(conn, 200)

      data = response["data"]

      assert is_list(data)
      assert length(data) == 1
      assert data |> Enum.any?(fn c -> c["id"] == complete_challenge.id end)
    end

    test "Returns upcoming challenges" do
      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)
      active_challenge = insert(:active_challenge)
      complete_challenge = insert(:complete_challenge)

      insert(:membership, account: account, challenge: upcoming_challenge)
      insert(:membership, account: account, challenge: active_challenge)
      insert(:membership, account: account, challenge: complete_challenge)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges?filter=upcoming"
        )

      response = json_response(conn, 200)

      data = response["data"]

      assert is_list(data)
      assert length(data) == 1
      assert data |> Enum.any?(fn c -> c["id"] == upcoming_challenge.id end)
    end
  end

  describe "show/3" do
    test "Returns the challenge preview" do
      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/#{upcoming_challenge.id}"
        )

      response = json_response(conn, 200)
      data = response["data"]

      assert data["name"] == "Challenge accepted!"
      assert data["profile_picture_url"] == "i.reddit.com/woop"

      conn =
        get(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/1235"
        )

      assert %{
               "status" => "failure",
               "error" => "A challenge with id (1235) does not exist."
             } = json_response(conn, 422)
    end
  end

  describe "update/3" do
    test "Updates challenge successfuly" do
      params = [
        start_date: "1999-01-23T13:27:32Z",
        end_date: "3999-01-29T12:47:00Z",
        name: "yooo",
        profile_picture_url: nil
      ]

      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)

      insert(:membership, account: account, challenge: upcoming_challenge, owner: true)

      conn =
        put(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/#{upcoming_challenge.id}",
          params
        )

      response = json_response(conn, 200)
      data = response["data"]

      assert data["start_date"] == "1999-01-23T13:27:32.000000Z"
      assert data["end_date"] == "3999-01-29T12:47:00.000000Z"
      assert data["name"] == "yooo"
      assert data["profile_picture_url"] == nil
    end

    test "Failure if not in challenge" do
      params = [
        start_date: "1999-01-23T13:27:32Z",
        end_date: "3999-01-29T12:47:00Z",
        name: "yooo",
        profile_picture_url: nil
      ]

      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)

      conn =
        put(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/#{upcoming_challenge.id}",
          params
        )

      assert %{
               "status" => "failure",
               "error" => "That challenge does not exist."
             } = json_response(conn, 422)
    end

    test "Failure if not owner" do
      params = [
        start_date: "1999-01-23T13:27:32Z",
        end_date: "3999-01-29T12:47:00Z",
        name: "yooo",
        profile_picture_url: nil
      ]

      account = insert(:account) |> Account.put_token()
      upcoming_challenge = insert(:upcoming_challenge)

      insert(:membership, account: account, challenge: upcoming_challenge, owner: false)

      conn =
        put(
          build_conn() |> put_req_header("authorization", account.token),
          "/challenges/#{upcoming_challenge.id}",
          params
        )

      assert %{
               "status" => "failure",
               "error" =>
                 "You are not authorized edit a challenge. Ask the challenge creator to do so."
             } = json_response(conn, 422)
    end
  end
end
