defmodule GymRatsWeb.Workout.CommentControllerTest do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account}

  import GymRats.Factory

  @endpoint GymRatsWeb.Endpoint

  describe "index/3" do
    test "removes a comment from existing" do
      account1 = insert(:account) |> Account.put_token()
      c1 = insert(:active_challenge, %{})
      insert(:membership, account: account1, challenge: c1)
      w1 = insert(:workout, account: account1, challenge: c1)
      comment = insert(:comment, account: account1, workout: w1)

      conn =
        get(
          build_conn() |> put_req_header("authorization", account1.token),
          "/workouts/#{w1.id}/comments"
        )

      assert %{"status" => "success"} = json_response(conn, 200)
      response = json_response(conn, 200)
      data = response["data"]

      assert is_list(data)
      assert data |> Enum.any?(fn c -> c["id"] == comment.id end)
    end
  end

  describe "create/3" do
    test "ceates a comment on a workout" do
      account1 = insert(:account) |> Account.put_token()
      c1 = insert(:active_challenge, %{})
      insert(:membership, account: account1, challenge: c1)
      w1 = insert(:workout, account: account1, challenge: c1)
      params = [content: "Cool."]

      conn =
        post(
          build_conn() |> put_req_header("authorization", account1.token),
          "/workouts/#{w1.id}/comments",
          params
        )

      assert %{"status" => "success"} = json_response(conn, 200)
    end
  end
end
