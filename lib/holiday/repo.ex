defmodule Holiday.Repo do
  use Ecto.Repo,
    otp_app: :holiday,
    adapter: Ecto.Adapters.Postgres
end
