defmodule GymRatsWeb.WorkoutControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account, Workout, Challenge}
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query

  @endpoint GymRatsWeb.Endpoint

  describe "create/3" do
    test "workout is created in all active challenges" do
      # account = insert(:account) |> Account.put_token()
      # c1 = insert(:active_challenge, %{})
      # c2 = insert(:active_challenge, %{})
      # c3 = insert(:complete_challenge, %{})
      # c4 = insert(:upcoming_challenge, %{})

      # insert(:membership, account: account, challenge: c1)
      # insert(:membership, account: account, challenge: c2)
      # insert(:membership, account: account, challenge: c3)
      # insert(:membership, account: account, challenge: c4)

      # params = [
      #   title: "Swell",
      #   description: "Lifting things up, putting them down.",
      #   steps: 1000,
      #   duration: 90,
      #   distance: "33.3",
      #   google_place_id: "x5134b1",
      #   photo_url: "firebase.com/pics/dfv9-12"
      # ]

      # conn =
      #   post(
      #     build_conn() |> put_req_header("authorization", account.token),
      #     "/workouts",
      #     params
      #   )

      # assert %{
      #          "data" => %{
      #            "calories" => nil,
      #            "description" => "Lifting things up, putting them down.",
      #            "distance" => "33.3",
      #            "duration" => 90,
      #            "google_place_id" => "x5134b1",
      #            "photo_url" => "firebase.com/pics/dfv9-12",
      #            "points" => nil,
      #            "steps" => 1000,
      #            "title" => "Swell"
      #          },
      #          "status" => "success"
      #        } = json_response(conn, 200)

      # account =
      #   Account
      #   |> preload(:workouts)
      #   |> Repo.get(account.id)

      # c1 =
      #   Challenge
      #   |> preload(:workouts)
      #   |> Repo.get(c1.id)

      # c2 =
      #   Challenge
      #   |> preload(:workouts)
      #   |> Repo.get(c2.id)

      # assert length(account.workouts) == 2
      # assert length(c1.workouts) == 1
      # assert length(c2.workouts) == 1
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
