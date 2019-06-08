defmodule Geomancer.Shapefile.CoordinatesTest do
  use ExUnit.Case
  alias Geomancer.Shapefile.Coordinates

  describe "parse/1" do
    test "parses an object with coordinates into coordinates" do
      object = %{x: 1.0, y: 2.0}
      assert Coordinates.parse(object) == [1.0, 2.0]
    end

    test "parses a list of objects with coordinates into a list of coordinates" do
      objects = [%{x: 1.0, y: 2.0}, %{x: 3.0, y: 4.0}]
      assert Coordinates.parse(objects) == [[1.0, 2.0], [3.0, 4.0]]
    end

    test "parses an object with coordinates nested in a map into coordinates" do
      object = %{a: "a", b: "b", c: %{x: 1.0, y: 2.0}}
      assert Coordinates.parse(object) == [1.0, 2.0]
    end

    test "parses a list of objects -- some with coordinates -- into a list of coordinates" do
      objects = [%{x: 1.0, y: 2.0}, "foo", nil, %{x: 3.0, y: 4.0}, :bar, 42]
      assert Coordinates.parse(objects) == [[1.0, 2.0], [3.0, 4.0]]
    end

    test "parses a list of lists of coordinates into a list of coordinates" do
      objects = [[[%{x: 1.0, y: 2.0}, %{x: 3.0, y: 4.0}, %{x: 5.0, y: 6.0}, %{x: 7.0, y: 8.0}]]]
      assert Coordinates.parse(objects) == [[[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [7.0, 8.0]]]
    end
  end
end
