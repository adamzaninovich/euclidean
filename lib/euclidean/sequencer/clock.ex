defmodule Euclidean.Sequencer.Clock do
  use GenServer

  def start_link(ticks_per_minute, opts \\ []) do
    GenServer.start_link(__MODULE__, %{tpm: ticks_per_minute}, opts)
  end

  def play(pid), do: GenServer.cast(pid, :play)
  def stop(pid), do: GenServer.cast(pid, :stop)

  def change_tempo(pid, new_tempo) do
    GenServer.cast(pid, {:change_tempo, new_tempo})
  end

  def init(%{tpm: tpm}) do
    {:ok, %{time: tick_time(tpm), running: false}}
  end

  def handle_cast(:play, state = %{running: true}), do: {:noreply, state}

  def handle_cast(:play, state = %{time: time, running: false}) do
    schedule_next_tick(time)
    {:noreply, %{state | running: true}}
  end

  def handle_cast({:change_tempo, tpm}, state) do
    {:noreply, %{state | time: tick_time(tpm)}}
  end

  def handle_info(:tick, state = %{running: false}), do: {:noreply, state}

  def handle_info(:tick, state = %{time: time}) do
    schedule_next_tick(time)
    Clock.PubSub.publish(:tick, self())
    {:noreply, state}
  end

  def handle_info(_message, state), do: {:noreply, state}

  defp schedule_next_tick(time) do
    Process.send_after(self(), :tick, time)
  end

  defp tick_time(tpm) do
    min = 60_000
    div(min, tpm)
  end
end
