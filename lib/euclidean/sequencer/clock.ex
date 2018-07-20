defmodule Euclidean.Sequencer.Clock do
  @moduledoc """
  The Sequencer Clock is used to run one or more Sequencer Tracks. Tracks
  subscribe to a clock using the Clock.PubSub server. You can have multiple
  clocks, but there is currently no way to sync them, which is kind of the idea.
  A single clock can run as many tracks as you want.
  """
  use GenServer

  alias Euclidean.Sequencer.Clock.PubSub

  @doc """
  Starts a new clock process linked to the caller's process

  Takes `ticks_per_minute` and `swing`

  `ticks_per_minute`, as opposed to BPM, is the actual steps/minute. This is
  computed into a time in milliseconds and is used to schedule ticks of the
  clock.

  `swing` is the percentage of swing. Straight is represented by 50.0 or 50%.
  Normal swing is anything above 50%. Below 50% is reverse swing.

  Returns `{:ok, clock_pid}` if everything started ok.
  """
  def start_link(ticks_per_minute, swing \\ 50.0, opts \\ []) do
    GenServer.start_link(__MODULE__, %{tpm: ticks_per_minute, swing: swing}, opts)
  end

  @doc "Sets a clock running, playing all subscribed tracks"
  def play(pid), do: GenServer.cast(pid, :play)

  @doc "Stops a running clock, pausing all subscribed tracks"
  def stop(pid), do: GenServer.cast(pid, :stop)

  @doc "Changes the tempo of the clock"
  def change_tempo(pid, new_tempo) do
    GenServer.cast(pid, {:change_tempo, new_tempo})
  end

  @doc "Changes the swing of the clock"
  def change_swing(pid, new_swing) do
    GenServer.cast(pid, {:change_swing, new_swing})
  end

  def init(%{tpm: tpm, swing: swing}) do
    {:ok, %{time: tick_time(tpm), swing: swing, beat: :down, running: false}}
  end

  def handle_cast(:play, state = %{running: true}), do: {:noreply, state}

  def handle_cast(:play, state = %{running: false, time: time, swing: swing, beat: beat}) do
    schedule_next_tick(time, swing, beat)
    {:noreply, %{state | running: true}}
  end

  def handle_cast(:stop, state = %{running: false}), do: {:noreply, state}

  def handle_cast(:stop, state = %{running: true}) do
    {:noreply, %{state | running: false}}
  end

  def handle_cast({:change_tempo, tpm}, state) do
    {:noreply, %{state | time: tick_time(tpm)}}
  end

  def handle_cast({:change_swing, swing}, state) do
    {:noreply, %{state | swing: swing}}
  end

  def handle_info(:tick, state = %{running: false}), do: {:noreply, state}

  def handle_info(:tick, state = %{time: time, swing: swing, beat: beat}) do
    schedule_next_tick(time, swing, beat)
    PubSub.publish(:tick, self())
    {:noreply, %{state | beat: next_beat(beat)}}
  end

  def handle_info(_message, state), do: {:noreply, state}

  defp schedule_next_tick(time, swing, :down) do
    swing_time = trunc(time * (swing - 50 + 100) / 100)
    Process.send_after(self(), :tick, swing_time)
  end

  defp schedule_next_tick(time, swing, :up) do
    swing_time = trunc(time * (50 - swing + 100) / 100)
    Process.send_after(self(), :tick, swing_time)
  end

  defp tick_time(tpm) do
    min = 60_000
    div(min, tpm)
  end

  defp next_beat(:up), do: :down
  defp next_beat(:down), do: :up
end
