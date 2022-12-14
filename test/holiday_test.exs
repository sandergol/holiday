defmodule HolidayTest do
  use ExUnit.Case
  doctest Holiday

  describe "Is a holiday:" do
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

  describe "Next holiday:" do
    test "Holiday in 1 day" do
      assert Holiday.init_db()
             |> Holiday.time_until_holiday(:day, ~U[2022-12-24 00:00:00.000000Z]) == 1.0
    end

    test "Holiday in 24 hour" do
      assert Holiday.init_db()
             |> Holiday.time_until_holiday(:hour, ~U[2022-12-24 00:00:00.000000Z]) == 24.0
    end

    test "Holiday in 1440 minute" do
      assert Holiday.init_db()
             |> Holiday.time_until_holiday(:minute, ~U[2022-12-24 00:00:00.000000Z]) == 1440.0
    end

    test "Holiday in 86400 second" do
      assert Holiday.init_db()
             |> Holiday.time_until_holiday(:second, ~U[2022-12-24 00:00:00.000000Z]) == 86400
    end
  end

  describe "Next holiday next year:" do
    test "Holiday in 6 day" do
      assert Holiday.time_until_holiday([], :day, ~U[2022-12-26 00:00:00.000000Z]) == 6.0
    end

    test "Holiday in 144 hour" do
      assert Holiday.time_until_holiday([], :hour, ~U[2022-12-26 00:00:00.000000Z]) == 144.0
    end

    test "Holiday in 8640 minute" do
      assert Holiday.time_until_holiday([], :minute, ~U[2022-12-26 00:00:00.000000Z]) == 8640.0
    end

    test "Holiday in 518400 second" do
      assert Holiday.time_until_holiday([], :second, ~U[2022-12-26 00:00:00.000000Z]) == 518_400
    end
  end
end
