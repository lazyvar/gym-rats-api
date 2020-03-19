defmodule GymRatsWeb.Open.RaiseController do
  use GymRatsWeb, :controller

  def go(_conn, _params) do
    raise "Abracadaba!"
  end
end
