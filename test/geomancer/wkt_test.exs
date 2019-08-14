defmodule Geomancer.WktTest do
  use ExUnit.Case
  doctest Geomancer.Wkt

  alias Geomancer.Wkt

  describe "format/0" do
    test "returns format name" do
      assert Wkt.format() == "Well Known Text"
    end
  end
end
