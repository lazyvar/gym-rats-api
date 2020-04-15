defmodule GymRats.Repo.Migrations.AddDescriptionAndScoreBy do
  use Ecto.Migration

  def change do
		alter table(:challenges) do
		  add :score_by, :string, default: "workouts"
		  add :description, :text
		end
  end
end
