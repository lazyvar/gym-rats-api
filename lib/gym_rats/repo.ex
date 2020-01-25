defmodule GymRats.Repo do
  use Ecto.Repo,
    otp_app: :gym_rats,
    adapter: Ecto.Adapters.Postgres
end
