defmodule GeomancerTest do
  use ExUnit.Case
  doctest Geomancer

  describe "geo_json/1" do
    test "converts multiple Shapefile points to FeatureCollection of multiple points" do
      fixture_map = fixture("point")
      geo_map = geo_map("point")
      assert geo_map == fixture_map
    end

    test "converts multiple Shapefile polygons to FeatureCollection of multiple polygons" do
      fixture_map = fixture("polygons")
      geo_map = geo_map("polygons")
      assert geo_map == fixture_map
    end

    test "returns error tuple for unsupported file format" do
      assert {:error, "Unsupported format: .bar"} = Geomancer.geo_json("foo.bar")
    end
  end

  def geo_map(name) do
    "test/support/#{name}.zip"
    |> Geomancer.geo_json()
    |> elem(1)
    |> Jason.decode!()
  end

  def fixture(name) do
    "test/support/#{name}.geojson"
    |> File.read!()
    |> Jason.decode!()
  end
end
