defmodule Holiday.Holiday do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  schema "holiday" do
    field(:dtstart, :utc_datetime)
    field(:dtend, :utc_datetime)
    field(:status, :string)
    field(:summary, :string)
  end

  def changeset(holiday, attrs \\ %{}) do
    holiday
    |> cast(attrs, [:id, :dtstart, :dtend, :status, :summary])
    |> validate_required([:id, :dtstart, :dtend, :status])
  end
end
