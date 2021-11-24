defmodule SolTracker.Application do
  use Application

  def start(_type, _args) do
    children = [
   #   {SolTracker.Client, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SolTracker.Supervisor)
  end
end