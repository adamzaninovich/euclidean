defmodule Beat do
  alias Euclidean.Sequencer
  alias Euclidean.Sequencer.Clock

  import Euclidean.Algorithm

  def init(tempo \\ 320, swing \\ 70.0) do
    {:ok, clock} = Clock.start_link(tempo, swing)

    {:ok, kick} = Sequencer.start_link(clock, euclid(4, 16) |> rotate(0), "hh_kick")
    {:ok, snare} = Sequencer.start_link(clock, euclid(3, 8) |> rotate(0), "hh_snare")
    {:ok, hat} = Sequencer.start_link(clock, euclid(11, 16) |> rotate(0), "hh_hat")
    {:ok, click} = Sequencer.start_link(clock, euclid(5, 8) |> rotate(0), "hh_click")

    {:ok, clock, [kick, snare, hat, click]}
  end

  def play(clock) do
    Clock.play(clock)
  end

  def stop(clock) do
    Clock.stop(clock)
  end

  def change_sequence(track, p, s, r \\ 0) do
    Sequencer.change_sequence(track, p, s, r)
  end

  def change_sequence(track, seq) do
    Sequencer.change_sequence(track, seq)
  end

  def change_tempo(clock, tempo) do
    Clock.change_tempo(clock, tempo)
  end

  def change_swing(clock, swing) do
    Clock.change_swing(clock, swing)
  end
end
