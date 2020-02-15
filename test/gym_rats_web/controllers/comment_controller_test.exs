defmodule GymRatsWeb.Open.CommentControllerTests do
  use GymRatsWeb.ConnCase

  alias GymRats.Model.{Account, Comment}
  alias GymRats.Repo

  import GymRats.Factory
  import Ecto.Query

  @endpoint GymRatsWeb.Endpoint

  describe "delete/3" do
    test "removes a comment from existing" do
      account = insert(:account) |> Account.put_token()
      comment = insert(:comment, %{account: account})

      conn =
        delete(
          build_conn() |> put_req_header("authorization", account.token),
          "/comments/#{comment.id}"
        )

      assert %{
               "status" => "success",
               "data" => %{
                 "content" => "Nice calves!"
               }
             } = json_response(conn, 200)

      comment = Comment |> Repo.get(comment.id)

      assert comment == nil
    end

    test "permissions" do
      account = insert(:account) |> Account.put_token()
      comment = insert(:comment)

      conn =
        delete(
          build_conn() |> put_req_header("authorization", account.token),
          "/comments/#{comment.id}"
        )

      expectation =
        assert %{
                 "status" => "failure",
                 "error" => "You do not have permission to do that."
               } = json_response(conn, 422)

      comment = Comment |> Repo.get(comment.id)

      assert comment != nil
    end
  end
end
