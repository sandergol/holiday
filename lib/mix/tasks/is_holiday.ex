defmodule Mix.Tasks.IsHoliday do
  @moduledoc "Is today a holiday?: `mix help is_holiday`"
  use Mix.Task

  @shortdoc "Вызывает функцию: Holiday.is_holiday/1"
  @spec run(any) :: :ok
  def run(_) do
    Mix.Task.run("app.start")

    if Holiday.is_holiday() do
      IO.puts("yes")
    else
      IO.puts("no")
    end
  end
end
