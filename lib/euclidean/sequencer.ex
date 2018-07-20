defmodule Euclidean.Sequencer do
  use GenServer

  def start_link(seq, spm, inst) do
    seq = List.to_tuple(seq)
    GenServer.start_link(__MODULE__, %{seq: seq, spm: spm, inst: inst})
  end

  def pause(pid) do
    GenServer.cast(pid, :pause)
  end

  def play(pid) do
    GenServer.cast(pid, :play)
  end

  def init(%{seq: seq, spm: spm, inst: inst}) do
    {:ok, %{seq: seq, index: 0, spm: spm, inst: inst, timer: :paused}}
  end

  def handle_cast(:pause, state = %{timer: :paused}) do
    {:noreply, state}
  end

  def handle_cast(:pause, state = %{timer: timer}) do
    :timer.cancel(timer)
    {:noreply, %{state | timer: :paused}}
  end

  def handle_cast(:play, state = %{spm: spm, timer: :paused}) do
    timer = schedule_next_tick(spm)
    {:noreply, %{state | timer: timer}}
  end

  def handle_cast(:play, state) do
    {:noreply, state}
  end

  def handle_info(:tick, state = %{timer: :paused}) do
    {:noreply, state}
  end

  def handle_info(:tick, %{seq: seq, index: index, spm: spm, inst: inst} = state) do
    timer = schedule_next_tick(spm)
    step = elem(seq, index)
    play_step(step, inst)

    {:noreply, %{state | index: next_index(seq, index), timer: timer}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def next_index(seq, index) when index >= tuple_size(seq) - 1, do: 0
  def next_index(_seq, index), do: index + 1

  defp play_step(0, _sound), do: :ok

  defp play_step(1, sound) do
    file = Path.join(:code.priv_dir(:euclidean), "sounds/#{sound}.aifc")

    Task.async(fn ->
      IO.puts(sound)
      System.cmd("/usr/bin/afplay", [file])
    end)

    :ok
  end

  defp tick_time(spm) do
    min = 60_000
    div(min, spm)
  end

  defp schedule_next_tick(spm) do
    Process.send_after(self(), :tick, tick_time(spm))
  end
end
