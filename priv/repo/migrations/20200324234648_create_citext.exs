defmodule GymRats.Repo.Migrations.CreateCitext do
  use Ecto.Migration

  def change do
  	if Mix.env == :dev do
	  	execute "CREATE EXTENSION IF NOT EXISTS citext"
  	end
  end
end