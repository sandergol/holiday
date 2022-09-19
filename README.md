# Holiday

**Determines whether today is a holiday or allows you to find out how long the holiday will be.**

## Getting started

1. Docker Container run:

    ```bash
    $ docker login
    $ docker run --name holiday -p 5432:5432 -e POSTGRES_PASSWORD=123456 -d postgres
    ```

    Or, if the container has already been created:

    ```bash
    $ docker start holiday
    ```

2. Run migrate:

    ```bash
    $ mix ecto.migrate
    ```

## USE

### `def init_db/0` parse list events holiday and write DB.

### `def is_holiday/1` return boolean

Examples:

```elixir
iex> Holiday.is_holiday(~D[2022-12-25])
true
iex> Holiday.is_holiday(~D[2022-12-27])
false
```

### `def time_until_holiday/2` return float until next holiday

The following units of measure are supported: `:day`, `:hour`, `:minute`, `:second`

Examples:

```elixir
iex> Holiday.time_until_holiday(:day, ~U[2022-12-23 00:10:00.000000Z])
1.99
iex> Holiday.time_until_holiday(:day, ~U[2021-12-23 00:00:00.000000Z])
2.0
iex> Holiday.time_until_holiday(:hour, ~U[2030-12-23 00:00:00.000000Z])
48.0
iex> Holiday.time_until_holiday(:day, ~U[2022-12-26 00:00:00.000000Z])
6.0
```
