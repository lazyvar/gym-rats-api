defmodule GymRatsWeb.PageController do
  use GymRatsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
