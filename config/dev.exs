use Mix.Config

config :holiday, Holiday.Repo,
  database: "postgres",
  username: "postgres",
  password: "123456",
  hostname: "localhost",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox
