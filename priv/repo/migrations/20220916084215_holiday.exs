defmodule Holiday.Repo.Migrations.Holiday do
  use Ecto.Migration

  def change do
    create table(:holiday, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :dtstart, :utc_datetime, null: false
      add :dtend, :utc_datetime, null: false
      add :status, :string, null: false
      add :summary, :string
    end
  end
end
