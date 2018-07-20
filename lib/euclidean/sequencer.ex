defmodule Euclidean.Sequencer do
  use GenServer

  alias Euclidean.Algorithm
  alias Euclidean.Sequencer.Clock.PubSub

  def start_link(clock, seq, inst) do
    seq = List.to_tuple(seq)
    GenServer.start_link(__MODULE__, %{seq: seq, clock: clock, inst: inst})
  end

  def change_sequence(sequencer, pulses, steps, rotation) do
    seq =
      pulses
      |> Algorithm.euclid(steps)
      |> Algorithm.rotate(rotation)
      |> List.to_tuple()

    GenServer.cast(sequencer, {:update_seq, seq})
  end

  def change_sequence(sequencer, new_seq) do
    GenServer.cast(sequencer, {:update_seq, List.to_tuple(new_seq)})
  end

  def init(%{seq: seq, clock: clock, inst: inst}) do
    PubSub.subscribe(self(), clock)
    {:ok, %{seq: seq, index: 0, clock: clock, inst: inst}}
  end

  def handle_cast({:update_seq, new_seq}, state = %{index: index}) do
    index =
      cond do
        index >= tuple_size(new_seq) - 1 -> 0
        true -> index
      end

    {:noreply, %{state | seq: new_seq, index: index}}
  end

  def handle_info({:tick, clock}, %{clock: clock, seq: seq, index: index, inst: inst} = state) do
    seq
    |> elem(index)
    |> play_step(inst, index)

    {:noreply, %{state | index: next_index(seq, index)}}
  end

  def handle_info(_, state), do: {:noreply, state}

  def next_index(seq, index) when index >= tuple_size(seq) - 1, do: 0
  def next_index(_seq, index), do: index + 1

  defp play_step(0, _sound, _i), do: :ok

  defp play_step(1, sound, index) do
    file = Path.join(:code.priv_dir(:euclidean), "sounds/#{sound}.aifc")

    Task.async(fn ->
      # IO.puts("#{index} - #{sound}")
      System.cmd("/usr/bin/afplay", [file])
    end)
  end
end
