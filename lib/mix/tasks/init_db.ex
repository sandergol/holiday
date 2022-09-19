defmodule Mix.Tasks.InitDb do
  @moduledoc "Parse calendar events and write to the DB: `mix help init_db`"
  use Mix.Task

  @shortdoc "Вызывает функцию: Holiday.init_db/0"
  @spec run(any) :: :ok
  def run(_) do
    Mix.Task.run("app.start")
    Holiday.init_db()
  end
end
