defmodule GeomancerTest do
  use ExUnit.Case
  doctest Geomancer

  test "greets the world" do
    assert Geomancer.hello() == :world
  end
end
