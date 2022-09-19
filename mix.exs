defmodule Holiday.MixProject do
  use Mix.Project

  def project do
    [
      app: :holiday,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Holiday.Application, []},
      applications: [
        :icalendar,
        :ecto,
        :ecto_sql,
        :postgrex
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:icalendar, "~> 1.1"},
      {:ecto, "~> 3.8"},
      {:ecto_sql, "~> 3.8"},
      {:postgrex, "~> 0.16.4"}
    ]
  end
end
