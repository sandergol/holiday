defmodule Mix.Tasks.IsHoliday do
  @moduledoc "Is today a holiday?: `mix help is_holiday`"
  use Mix.Task

  @shortdoc "Вызывает функцию: Holiday.init_db/0 |> Holiday.is_holiday/1"
  def run(_) do
    if Holiday.init_db() |> Holiday.is_holiday() do
      IO.puts("yes")
    else
      IO.puts("no")
    end
  end
end
