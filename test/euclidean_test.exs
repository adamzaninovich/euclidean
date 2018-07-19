defmodule EuclideanTest do
  use ExUnit.Case
  doctest Euclidean

  test "greets the world" do
    assert Euclidean.hello() == :world
  end
end
