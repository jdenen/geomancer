defmodule Geomancer.GeoJsonTest do
  use ExUnit.Case
  doctest Geomancer.GeoJson

  alias Geomancer.GeoJson

  describe "convert/2" do
    test "converts Shapefile points to valid GeoJson" do
      fixture_map = fixture("point")

      converted_map =
        "test/support/point.zip"
        |> GeoJson.convert()
        |> elem(1)
        |> Jason.decode!()

      assert converted_map == fixture_map
    end

    test "recognizes multiple Shapefile extensions" do
      assert {_, shapefile} = GeoJson.convert("foo.shapefile")
      assert {_, shp} = GeoJson.convert("bar.shp")

      assert String.contains?(shapefile, "Shapefile")
      assert String.contains?(shp, "Shapefile")
    end

    test "converts Shapefile polygons to valid GeoJson" do
      fixture_map = fixture("polygons")

      converted_map =
        "test/support/polygons.zip"
        |> GeoJson.convert()
        |> elem(1)
        |> Jason.decode!()

      assert converted_map == fixture_map
    end

    test "returns error tuple for unsupported file formats" do
      assert {:error, "Conversion from bar to GeoJSON is unsupported"} =
               GeoJson.convert("foo", :bar)
    end
  end

  describe "read/1" do
    test "returns ok tuple with map contents" do
      assert {:ok, contents} = GeoJson.read("test/support/point.geojson")
      assert is_map(contents)
    end

    test "returns error tuple if file cannot be read" do
      assert {:error, reason} = GeoJson.read("foo.bar")
      assert reason == "Cannot open file 'foo.bar': enoent"
    end
  end

  describe "format/0" do
    test "returns format name" do
      assert GeoJson.format() == "GeoJSON"
    end
  end

  defp fixture(name) do
    "test/support/#{name}.geojson"
    |> File.read!()
    |> Jason.decode!()
  end
end
