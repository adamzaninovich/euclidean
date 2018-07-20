defmodule Song do
  alias Euclidean.Sequencer
  import Euclidean.Algorithm

  def init do
    t = 160

    {:ok, kick} = Sequencer.start_link(euclid(3, 16), t * 2, "hh_kick")
    {:ok, snare} = Sequencer.start_link(euclid(2, 8) |> rotate(2), t, "hh_snare")
    {:ok, hat} = Sequencer.start_link(euclid(9, 16) |> rotate(2), t * 2, "hh_hat")
    {:ok, click} = Sequencer.start_link(euclid(5, 8) |> rotate(1), t, "hh_click")

    [kick, snare, hat, click]
  end

  def play(tracks) do
    tracks
    |> Enum.map(&fn -> Sequencer.play(&1) end)
    |> Enum.each(&Task.async/1)
  end

  def pause(tracks) do
    tracks
    |> Enum.map(&fn -> Sequencer.pause(&1) end)
    |> Enum.each(&Task.async/1)
  end
end
