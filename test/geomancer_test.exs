defmodule GeomancerTest do
  use ExUnit.Case
  doctest Geomancer

  describe "geo_json/1" do
    test "converts Shapefile with Points to GeoJSON" do
      fixture_map = "test/support/point.geojson" |> File.read!() |> Jason.decode!()
      assert {:ok, geo_json} = Geomancer.geo_json("test/support/point.zip")
      geo_map = Jason.decode!(geo_json)
      assert geo_map == fixture_map
    end

    test "converts Shapefile with Polygons to GeoJSON" do
      fixture_map = "test/support/Campus_Boundary.geojson" |> File.read!() |> Jason.decode!()
      assert {:ok, geo_json} = Geomancer.geo_json("test/support/Campus_Boundary.zip")
      geo_map = Jason.decode!(geo_json)
      assert geo_map == fixture_map
    end

    test "converts Shapefile with MultiPolygons to GeoJSON" do
      fixture_map = "test/support/Urban_Services_Boundary.geojson" |> File.read!() |> Jason.decode!()
      assert {:ok, geo_json} = Geomancer.geo_json("test/support/Urban_Services_Boundary.zip")
      geo_map = Jason.decode!(geo_json)
      assert geo_map == fixture_map
    end

    test "returns error tuple for unsupported file format" do
      assert {:error, "Unsupported format: .bar"} = Geomancer.geo_json("foo.bar")
    end
  end
end
