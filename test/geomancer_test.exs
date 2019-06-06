defmodule GeomancerTest do
  use ExUnit.Case
  doctest Geomancer

  describe "geo_json/1" do
    test "returns error tuple for unsupported file format" do
      assert {:error, "Unsupported format: .bar"} = Geomancer.geo_json("foo.bar")
    end
  end
end
