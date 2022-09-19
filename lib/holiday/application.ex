defmodule Holiday.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Holiday.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Holiday.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
