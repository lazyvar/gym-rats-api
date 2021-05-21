defmodule GymRats.Repo.Migrations.AddAndroidDevices do
  use Ecto.Migration

  def change do
    create table(:android_devices) do
      add :account_id, :bigint, null: false
      add :token, :string, null: false

      timestamps()
    end

    create index(:android_devices, [:account_id])
  end
end
