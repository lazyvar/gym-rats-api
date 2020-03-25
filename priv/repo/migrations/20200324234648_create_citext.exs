defmodule GymRats.Repo.Migrations.CreateCitext do
  use Ecto.Migration

  def change do
  	if Mix.env == :dev || Mix.env == :test do
	  	execute "CREATE EXTENSION IF NOT EXISTS citext"
  	end
  end
end