defmodule Holiday do
  @holidays_path Path.join(["date", "us-california-nonworkingdays.ics"])

  @moduledoc """
  Documentation for `Holiday`.
  """

  @doc """
  def init_db/0 return list events holiday.

  Example list:

  ```elixir
  [
    %ICalendar.Event{
      summary: "Film with Amy and Adam",
      dtstart: {{2015, 12, 24}, {8, 30, 00}},
      dtend:   {{2015, 12, 24}, {8, 45, 00}},
      description: "Let's go see Star Wars.",
      location: "123 Fun Street, Toronto ON, Canada"
    },
    %ICalendar.Event{
      summary: "Morning meeting",
      dtstart: Timex.now,
      dtend:   Timex.shift(Timex.now, hours: 3),
      description: "A big long meeting with lots of details.",
      location: "456 Boring Street, Toronto ON, Canada"
    },
  ]
  ```
  """
  @spec init_db :: List.t()
  def init_db do
    File.read!(@holidays_path) |> ICalendar.from_ics()
  end

  @doc """
  def is_holiday/2 return boolean.

  ## Examples
    iex> Holiday.init_db() |> Holiday.is_holiday(~D[2022-12-25])
    true
    iex> Holiday.init_db() |> Holiday.is_holiday(~D[2022-12-26])
    false
  """
  @spec is_holiday(db :: List.t(), day :: Date.t()) :: boolean
  def is_holiday(db, day \\ Date.utc_today()) do
    if db == [] do
      false
    else
      date_time =
        case DateTime.new(day, Time.utc_now()) do
          {:ok, date} -> date
        end

      date_time =
        if date_time.year < Date.utc_today().year, do: change_year(date_time), else: date_time

      holiday = date_diff(change_year(hd(db).dtstart), change_year(hd(db).dtend), date_time)

      cond do
        holiday.start <= 0 and holiday.end >= 0 -> true
        true -> is_holiday(tl(db), day)
      end
    end
  end

  @doc """
  def time_until_holiday/3 return float until next holiday.

  > The following units of measure are supported:
  > :day
  > :hour
  > :minute
  > :second

  ## Examples
    iex> Holiday.init_db() |> Holiday.time_until_holiday(:day, ~U[2022-12-23 00:10:00.000000Z])
    1.99
    iex> Holiday.init_db() |> Holiday.time_until_holiday(:day, ~U[2021-12-23 00:00:00.000000Z])
    2.0
    iex> Holiday.init_db() |> Holiday.time_until_holiday(:hour, ~U[2030-12-23 00:00:00.000000Z])
    48.0

  If you do not pass a database as the first argument, it will look for the next holiday in the next year.

  ## Examples
    iex> Holiday.time_until_holiday([], :hour, ~U[2022-12-23 00:00:00.000000Z])
    216.0
  """
  @spec time_until_holiday(
          db :: List.t(),
          unit :: atom,
          now :: DateTime.t()
        ) :: false | number
  def time_until_holiday(db, unit, now \\ DateTime.utc_now()) do
    if db == [] do
      next_holiday_next_year(init_db(), now, unit)
    else
      dtstart = change_year(hd(db).dtstart, now.year)
      dtend = change_year(hd(db).dtend, now.year)

      holiday = date_diff(dtstart, dtend, now, unit)

      cond do
        holiday.start <= 0 ->
          time_until_holiday(tl(db), unit, now)

        true ->
          holiday.start
      end
    end
  end

  @spec next_holiday_next_year(
          db :: List.t(),
          date_time :: DateTime.t(),
          unit :: atom,
          before_start :: nil | number
        ) :: number | false
  defp next_holiday_next_year(db, date_time, unit, before_start \\ nil) do
    if db == [] do
      false
    else
      dtstart = change_year(hd(db).dtstart, date_time.year + 1)
      dtend = change_year(hd(db).dtend, date_time.year + 1)

      holiday = date_diff(dtstart, dtend, date_time, unit)

      cond do
        before_start >= holiday.start and tl(db) != [] ->
          next_holiday_next_year(tl(db), date_time, unit, holiday.start)

        true ->
          before_start
      end
    end
  end

  @spec date_diff(
          dtstart :: DateTime.t(),
          dtend :: DateTime.t(),
          custom_data :: DateTime.t(),
          unit :: atom
        ) :: %{start: number, end: number}
  defp date_diff(dtstart, dtend, custom_data, unit \\ :day) do
    holiday_start = DateTime.diff(dtstart, custom_data)
    holiday_end = DateTime.diff(dtend, custom_data)

    case unit do
      :day ->
        %{
          start: round(holiday_start / 60 / 60 / 24 * 100) / 100,
          end: round(holiday_end / 60 / 60 / 24 * 100) / 100
        }

      :hour ->
        %{
          start: round(holiday_start / 60 / 60 * 100) / 100,
          end: round(holiday_end / 60 / 60 * 100) / 100
        }

      :minute ->
        %{
          start: round(holiday_start / 60 * 100) / 100,
          end: round(holiday_end / 60 * 100) / 100
        }

      :second ->
        %{start: holiday_start, end: holiday_end}
    end
  end

  @spec change_year(date_time :: DateTime.t(), year :: number) :: DateTime.t()
  defp change_year(date_time, year \\ Date.utc_today().year) do
    date =
      case Date.new(year, date_time.month, date_time.day) do
        {:ok, date} -> date
      end

    time =
      case Time.new(date_time.hour, date_time.minute, date_time.second) do
        {:ok, time} -> time
      end

    case DateTime.new(date, time) do
      {:ok, date_time} -> date_time
    end
  end
end
