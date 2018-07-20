defmodule Euclidean.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    [
      # Starts a worker by calling:
      # Euclidean.Sequencer.Clock.PubSub.start_link([])
      {Euclidean.Sequencer.Clock.PubSub, []}
    ]
    |> Supervisor.start_link(strategy: :one_for_one, name: Euclidean.Supervisor)
  end
end
