defmodule Geomancer.GeoJsonTest do
  use ExUnit.Case
  doctest Geomancer.GeoJson

  describe "convert/1" do
    test "converts Shapefile points to valid GeoJson" do
      fixture_map = fixture("point")

      converted_map =
        "test/support/point.zip"
        |> Geomancer.GeoJson.convert()
        |> elem(1)
        |> Jason.decode!()

      assert converted_map == fixture_map
    end

    test "recognizes multiple Shapefile extensions" do
      assert {_, shapefile} = Geomancer.GeoJson.convert("foo.shapefile")
      assert {_, shp} = Geomancer.GeoJson.convert("bar.shp")

      assert String.contains?(shapefile, "Shapefile")
      assert String.contains?(shp, "Shapefile")
    end

    test "converts Shapefile polygons to valid GeoJson" do
      fixture_map = fixture("polygons")

      converted_map =
        "test/support/polygons.zip"
        |> Geomancer.GeoJson.convert()
        |> elem(1)
        |> Jason.decode!()

      assert converted_map == fixture_map
    end

    test "returns error tuple for unsupported file formats" do
      assert {:error, "Unsupported format: .bar"} = Geomancer.GeoJson.convert("foo.bar")
    end
  end

  describe "read/1" do
    test "returns ok tuple with map contents" do
      assert {:ok, contents} = Geomancer.GeoJson.read("test/support/point.geojson")
      assert is_map(contents)
    end

    test "returns error tuple if file cannot be read" do
      assert {:error, reason} = Geomancer.GeoJson.read("foo.bar")
      assert reason == "Cannot open file 'foo.bar': enoent"
    end
  end

  defp fixture(name) do
    "test/support/#{name}.geojson"
    |> File.read!()
    |> Jason.decode!()
  end
end
