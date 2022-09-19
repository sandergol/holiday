defmodule Holiday do
  import Ecto.Query

  @holidays_path Path.join(["date", "us-california-nonworkingdays.ics"])

  @moduledoc """
  Documentation for `Holiday`.
  """

  @doc """
  def `init_db/0` parse list events holiday and write DB.
  """
  @spec init_db :: :ok
  def init_db do
    File.read!(@holidays_path)
    |> ICalendar.from_ics()
    |> Enum.each(fn el ->
      changeset =
        Holiday.Holiday.changeset(%Holiday.Holiday{
          id: el.uid,
          dtstart: el.dtstart,
          dtend: el.dtend,
          status: String.downcase(el.status),
          summary: el.summary
        })

      if Holiday.Holiday |> Holiday.Repo.get(el.uid) do
        Holiday.Repo.update!(changeset)
      else
        Holiday.Repo.insert!(changeset)
      end
    end)
  end

  @doc """
  def `is_holiday/1` return boolean.

  ## Examples
    iex> Holiday.is_holiday(~D[2022-12-25])
    true
    iex> Holiday.is_holiday(~D[2022-12-27])
    false
  """
  @spec is_holiday(day :: Date.t()) :: boolean
  def is_holiday(day \\ Date.utc_today()) do
    query =
      from(h in Holiday.Holiday,
        where:
          h.status == "confirmed" and
            ((fragment("date_part('year', ?)", h.dtstart) <= ^day.year and
                fragment("date_part('month', ?)", h.dtstart) == ^day.month and
                fragment("date_part('day', ?)", h.dtstart) == ^day.day) or
               (fragment("date_part('year', ?)", h.dtend) <= ^day.year and
                  fragment("date_part('month', ?)", h.dtend) == ^day.month and
                  fragment("date_part('day', ?)", h.dtend) == ^day.day))
      )

    Holiday.Repo.all(query) != []
  end

  @doc """
  def `time_until_holiday/2` return float until next holiday.

  > The following units of measure are supported:
  > :day
  > :hour
  > :minute
  > :second

  ## Examples
    iex> Holiday.time_until_holiday(:day, ~U[2022-12-23 00:10:00.000000Z])
    1.99
    iex> Holiday.time_until_holiday(:day, ~U[2021-12-23 00:00:00.000000Z])
    2.0
    iex> Holiday.time_until_holiday(:hour, ~U[2030-12-23 00:00:00.000000Z])
    48.0
  """
  @spec time_until_holiday(
          unit :: atom,
          now :: DateTime.t()
        ) :: number
  def time_until_holiday(unit, now \\ DateTime.utc_now()) do
    query =
      from(h in Holiday.Holiday,
        where:
          h.status == "confirmed" and
            ((fragment("date_part('year', ?)", h.dtstart) <= ^now.year and
                fragment("date_part('month', ?)", h.dtstart) == ^now.month and
                fragment("date_part('day', ?)", h.dtstart) > ^now.day) or
               (fragment("date_part('year', ?)", h.dtstart) <= ^now.year and
                  fragment("date_part('month', ?)", h.dtstart) > ^now.month)),
        order_by: [asc: h.dtstart],
        limit: 1
      )

    result =
      case next = List.first(Holiday.Repo.all(query)) do
        nil ->
          query =
            from(h in Holiday.Holiday,
              where: fragment("date_part('month', ?)", h.dtstart) >= 01,
              order_by: [asc: h.dtstart],
              limit: 1
            )

          %{next: List.first(Holiday.Repo.all(query)), year: now.year + 1}

        _ ->
          %{next: next, year: now.year}
      end

    dtstart = change_year(result.next.dtstart, result.year)
    dtend = change_year(result.next.dtend, result.year)

    date_diff(dtstart, dtend, now, unit).start
  end

  @spec date_diff(
          dtstart :: DateTime.t(),
          dtend :: DateTime.t(),
          custom_data :: DateTime.t(),
          unit :: atom
        ) :: %{start: number, end: number}
  defp date_diff(dtstart, dtend, custom_data, unit) do
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
  defp change_year(date_time, year) do
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
