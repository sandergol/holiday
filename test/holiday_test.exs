defmodule HolidayTest do
  use ExUnit.Case
  doctest Holiday

  test "greets the world" do
    assert Holiday.hello() == :world
  end

  test "list received" do
    assert Holiday.init_db() |> is_list()
  end

  test "today is a holiday" do
    assert Holiday.init_db() |> Holiday.is_holiday(~D[2022-12-25])
  end

  test "today is not holiday" do
    refute Holiday.init_db() |> Holiday.is_holiday(~D[2022-12-26])
  end
end
