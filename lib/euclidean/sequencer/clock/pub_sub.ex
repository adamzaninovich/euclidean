defmodule Euclidean.Sequencer.Clock.PubSub do
  @moduledoc """
  The PubSub server is used to subscribe tracks to clocks and publishing ticks
  from those clocks to all subscribed tracks.
  """
  use GenServer

  def start_link(opts \\ []) do
    opts = Keyword.merge(opts, name: __MODULE__)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def subscribe(pid, clock) do
    GenServer.call(__MODULE__, {:subscribe, pid, clock})
  end

  def unsubscribe(pid, clock) do
    GenServer.call(__MODULE__, {:unsubscribe, pid, clock})
  end

  def publish(message, from) do
    GenServer.cast(__MODULE__, {:publish, message, from})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:subscribe, sub, clock}, _from, state) do
    {:reply, :ok, add_sub(sub, clock, state)}
  end

  def handle_call({:unsubscribe, sub, clock}, _from, state) do
    {:reply, :ok, remove_sub(sub, clock, state)}
  end

  def handle_cast({:publish, message, clock}, state) do
    subs = Map.get(state, clock, [])
    for sub <- subs, do: send(sub, {message, clock})
    {:noreply, state}
  end

  defp add_sub(sub, clock, state) do
    subs_for_clock = Map.get(state, clock, [])
    Map.put(state, clock, Enum.uniq([sub | subs_for_clock]))
  end

  defp remove_sub(sub, clock, state) do
    subs_for_clock =
      state
      |> Map.get(clock, [])
      |> List.delete(sub)

    Map.put(state, clock, subs_for_clock)
  end
end
