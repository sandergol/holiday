import Config

config :holiday, ecto_repos: [Holiday.Repo]

config :holiday, Holiday.Repo,
  database: "postgres",
  username: "postgres",
  password: "123456",
  hostname: "localhost",
  port: "5432"

import_config "#{Mix.env()}.exs"
