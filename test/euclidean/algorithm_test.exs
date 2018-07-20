defmodule Euclidean.AlgorithmTest do
  use ExUnit.Case, async: true

  import Euclidean.Algorithm

  test "rotate rotates a sequence left for positive and right for negative" do
    assert rotate([1, 0], 1) == [0, 1]
    assert rotate([0, 1, 0], 1) == [1, 0, 0]
    assert rotate([0, 1, 0], -1) == [0, 0, 1]
    assert rotate([1, 0, 0], 3) == [1, 0, 0]
    assert rotate([1, 0, 0], -3) == [1, 0, 0]
  end

  test "euclid returns a sequence" do
    assert euclid(0, 8) == [0, 0, 0, 0, 0, 0, 0, 0]

    assert euclid(1, 8) == [1, 0, 0, 0, 0, 0, 0, 0]
    assert euclid(2, 8) == [1, 0, 0, 0, 1, 0, 0, 0]
    assert euclid(3, 8) == [1, 0, 0, 1, 0, 0, 1, 0]
    assert euclid(4, 8) == [1, 0, 1, 0, 1, 0, 1, 0]

    assert euclid(5, 8) == [1, 0, 1, 1, 0, 1, 1, 0]
    assert euclid(6, 8) == [1, 1, 1, 0, 1, 1, 1, 0]
    assert euclid(7, 8) == [1, 1, 1, 1, 1, 1, 1, 0]

    assert euclid(8, 8) == [1, 1, 1, 1, 1, 1, 1, 1]

    assert euclid(5, 7) == [1, 1, 0, 1, 1, 1, 0]
    assert euclid(4, 11) == [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0]
    assert euclid(5, 16) == [1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]
  end

  test "euclid returns an error when the k > n" do
    assert {:error, _message} = euclid(9, 8)
  end
end
