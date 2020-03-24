defmodule GymRats.Repo.Migrations.CreateCitext do
  use Ecto.Migration

  def change do
  	execute "CREATE EXTENSION IF NOT EXISTS citext"
  end
end