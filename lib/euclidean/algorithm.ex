defmodule Euclidean.Algorithm do
  @moduledoc """
  The Euclidean algorithm is a way to find the greatest common divisor of two
  positive integers, a and b. Here is a paper on the subject:

  http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf

  In terms of Euclidean Sequencing in generative music, we have a set number of
  steps and need to divide pulses between them in the most even way possible.

  This uses a variation of the Euclidean Algorithm called the Bjorklund
  Algorithm which works by representing this problem as a binary sequence of k
  one's and n − k zero's, where each integer represents a time interval, and
  the one's represent the pulses. The problem then reduces to the following:
  construct a binary sequence of n bits with k one's, such that the k one's are
  distributed as evenly as possible among the zero's.
  """

  @type step :: 0 | 1
  @type sequence :: [step()]

  @spec rotate(sequence(), integer()) :: sequence()
  def rotate(seq, 0), do: seq

  def rotate([step | seq], n) when n > 0 do
    rotate(seq ++ [step], n - 1)
  end

  def rotate(seq, n) when n < 0 do
    seq
    |> :lists.reverse()
    |> rotate(-n)
    |> :lists.reverse()
  end

  @spec euclid(pos_integer(), pos_integer()) :: sequence()
  def euclid(pulses, steps) when pulses > steps do
    {:error, "You cannot have more pulses than steps"}
  end

  def euclid(0, steps), do: List.duplicate(0, steps)
  def euclid(steps, steps), do: List.duplicate(1, steps)

  def euclid(pulses, steps) when div(steps, pulses) > 1 do
    pauses = steps - pulses
    per_pulse = div(pauses, pulses)
    remainder = rem(pauses, pulses)

    0..(pulses - 1)
    |> Enum.reduce([], fn pulse, seq ->
      seq = List.duplicate(0, per_pulse) ++ [1 | seq]

      if pulse < remainder do
        [0 | seq]
      else
        seq
      end
    end)
    |> Enum.reverse()
  end

  def euclid(pulses, steps) do
    (steps - pulses)
    |> euclid(steps)
    |> Enum.reverse()
    |> Enum.map(fn
      1 -> 0
      0 -> 1
    end)
  end
end
