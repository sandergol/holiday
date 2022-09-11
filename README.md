# Holiday

**Determines whether today is a holiday or allows you to find out how long the holiday will be.**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `holiday` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:holiday, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/holiday>.

## USE

### `def init_db/0` return list events holiday

**Example list**:

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

### `def is_holiday/2` return boolean

**Examples**

  ```elixir
  iex> Holiday.init_db() |> Holiday.is_holiday(~D[2022-12-25])
  true
  iex> Holiday.init_db() |> Holiday.is_holiday(~D[2022-12-26])
  false
  ```

### `def time_until_holiday/3` return float until next holiday

> The following units of measure are supported:
>
> `:day`, `:hour`, `:minute`, `:second`

**Examples**

  ```elixir
  iex> Holiday.init_db() |> Holiday.time_until_holiday(:day, ~U[2022-12-23 00:10:00.000000Z])
  1.99
  iex> Holiday.init_db() |> Holiday.time_until_holiday(:day, ~U[2021-12-23 00:00:00.000000Z])
  2.0
  iex> Holiday.init_db() |> Holiday.time_until_holiday(:hour, ~U[2030-12-23 00:00:00.000000Z])
  48.0
  ```

If you do not pass a database as the first argument, it will look for the next holiday in the next year.

**Examples**

  ```elixir
  iex> Holiday.time_until_holiday([], :hour, ~U[2022-12-23 00:00:00.000000Z])
  216.0
  ```
