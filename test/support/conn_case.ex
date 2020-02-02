defmodule GymRatsWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      alias GymRatsWeb.Router.Helpers, as: Routes

      @endpoint GymRatsWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(GymRats.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(GymRats.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
