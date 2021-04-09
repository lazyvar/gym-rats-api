defmodule GymRatsWeb.WorkoutControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account, Workout, Challenge}
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query

  @endpoint GymRatsWeb.Endpoint

  describe "create/3" do
    test "rejects commas" do
      challenge = insert(:active_challenge, %{})
      account = insert(:account) |> Account.put_token()
      insert(:membership, account: account, challenge: challenge)

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "33,3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 422)

      assert response["error"] == "Distance has invalid format"
    end

    test "rejects double periods" do
      challenge = insert(:active_challenge, %{})
      account = insert(:account) |> Account.put_token()
      insert(:membership, account: account, challenge: challenge)

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "12..3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 422)

      assert response["error"] == "Distance has invalid format"
    end

    test "accepts some stuff" do
      challenge = insert(:active_challenge, %{})
      account = insert(:account) |> Account.put_token()
      insert(:membership, account: account, challenge: challenge)

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "12.",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["distance"] == "12."

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: ".0",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["distance"] == ".0"

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "1.5",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["distance"] == "1.5"
    end

    test "safeguards activity type" do
      challenge = insert(:active_challenge, %{})
      account = insert(:account) |> Account.put_token()
      insert(:membership, account: account, challenge: challenge)

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        activity_type: "volleyball",
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["activity_type"] == "other"
      assert response["data"]["activity_type_version_two"] == "volleyball"

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        activity_type: "running",
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["activity_type"] == "running"
      assert response["data"]["activity_type_version_two"] == "running"

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        activity_type: "other",
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["activity_type"] == "other"
      assert response["data"]["activity_type_version_two"] == "other"

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["activity_type"] == nil
      assert response["data"]["activity_type_version_two"] == nil

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        activity_type: "dance",
        distance: "33.3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["activity_type"] == "other"
      assert response["data"]["activity_type_version_two"] == "dance"

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        activity_type: "cycling",
        distance: "33.3",
        google_place_id: "x5134b1",
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert response["data"]["activity_type"] == "cycling"
      assert response["data"]["activity_type_version_two"] == "cycling"
    end

    test "multiple media upload" do
      media1 = %{url: "https://www.image.com/jpg", medium_type: "image/jpg"}
      media2 = %{url: "https://www.image.com/jpg", medium_type: "image/jpg"}
      media3 = %{url: "https://www.video.com/mp3", medium_type: "video/mp4"}

      challenge = insert(:active_challenge, %{})
      account = insert(:account) |> Account.put_token()
      insert(:membership, account: account, challenge: challenge)

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        media: [media1, media2, media3],
        challenges: [challenge.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      response = json_response(conn, 200)

      assert is_list(response["data"]["media"])
      assert response["data"]["photo_url"] == "https://www.image.com/jpg"
    end

    test "no challenges results in failure" do
      account = insert(:account) |> Account.put_token()

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        photo_url: "firebase.com/pics/dfv9-12"
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      assert %{
               "error" => "No challenges provided.",
               "status" => "failure"
             } = json_response(conn, 422)
    end

    test "workout is created in all active challenges" do
      account = insert(:account) |> Account.put_token()
      c1 = insert(:active_challenge, %{})
      c2 = insert(:active_challenge, %{})
      c3 = insert(:complete_challenge, %{})
      c4 = insert(:upcoming_challenge, %{})

      insert(:membership, account: account, challenge: c1)
      insert(:membership, account: account, challenge: c2)
      insert(:membership, account: account, challenge: c3)
      insert(:membership, account: account, challenge: c4)

      params = [
        title: "Swell",
        description: "Lifting things up, putting them down.",
        steps: 1000,
        duration: 90,
        distance: "33.3",
        google_place_id: "x5134b1",
        photo_url: "firebase.com/pics/dfv9-12",
        challenges: [c1.id, c2.id, c3.id, c4.id]
      ]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts",
          params
        )

      assert %{
               "data" => %{
                 "calories" => nil,
                 "description" => "Lifting things up, putting them down.",
                 "distance" => "33.3",
                 "duration" => 90,
                 "google_place_id" => "x5134b1",
                 "photo_url" => "firebase.com/pics/dfv9-12",
                 "points" => nil,
                 "steps" => 1000,
                 "title" => "Swell"
               },
               "status" => "success"
             } = json_response(conn, 200)

      account =
        Account
        |> preload(:workouts)
        |> Repo.get(account.id)

      c1 =
        Challenge
        |> preload(:workouts)
        |> Repo.get(c1.id)

      c2 =
        Challenge
        |> preload(:workouts)
        |> Repo.get(c2.id)

      c3 =
        Challenge
        |> preload(:workouts)
        |> Repo.get(c3.id)

      c4 =
        Challenge
        |> preload(:workouts)
        |> Repo.get(c4.id)

      assert length(account.workouts) == 4
      assert length(c1.workouts) == 1
      assert length(c2.workouts) == 1
      assert length(c3.workouts) == 1
      assert length(c4.workouts) == 1
    end
  end

  describe "delete/3" do
    test "removes a workout from existing" do
      account = insert(:account) |> Account.put_token()
      workout = insert(:workout, %{account: account})

      conn =
        delete(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts/#{workout.id}"
        )

      assert %{
               "data" => %{
                 "calories" => nil,
                 "description" => "You already know.",
                 "distance" => "33.3",
                 "duration" => 90,
                 "google_place_id" => "x5134b1",
                 "photo_url" => "firebase.com/pics/dfv9-12",
                 "points" => nil,
                 "steps" => 1000,
                 "title" => "Swoll."
               },
               "status" => "success"
             } = json_response(conn, 200)

      workout = Workout |> Repo.get(workout.id)

      assert workout == nil
    end

    test "permissions" do
      account = insert(:account) |> Account.put_token()
      workout = insert(:workout)

      conn =
        delete(
          build_conn() |> put_req_header("authorization", account.token),
          "/workouts/#{workout.id}"
        )

      assert %{
               "status" => "failure",
               "error" => "You do not have permission to do that."
             } = json_response(conn, 422)

      workout = Workout |> Repo.get(workout.id)

      assert workout != nil
    end
  end
end
