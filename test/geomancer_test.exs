defmodule GeomancerTest do
  use ExUnit.Case
  doctest Geomancer

  @point_map %{
    type: "FeatureCollection",
    name: "point",
    features: [
      %{
        type: "Feature",
        properties: %{
          point_ID: nil
        },
        geometry: %{
          type: "Point",
          coordinates: [10.0, 10.0]
        }
      },
      %{
        type: "Feature",
        properties: %{
          point_ID: nil
        },
        geometry: %{
          type: "Point",
          coordinates: [5.0, 5.0]
        }
      },
      %{
        type: "Feature",
        properties: %{
          point_ID: nil
        },
        geometry: %{
          type: "Point",
          coordinates: [0.0, 10.0]
        }
      }
    ]
  }

  describe "geo_json/1" do
    test "converts Shapefile to GeoJSON" do
      assert {:ok, geo_json} = Geomancer.geo_json("test/support/point.zip")
      assert geo_json == Jason.encode!(@point_map)
    end

    test "returns error tuple for unsupported file format" do
      assert {:error, "Unsupported format: .bar"} = Geomancer.geo_json("foo.bar")
    end
  end
end
