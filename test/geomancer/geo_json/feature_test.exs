defmodule Geomancer.GeoJson.FeatureTest do
  use ExUnit.Case
  doctest Geomancer.GeoJson.Feature
  alias Geomancer.GeoJson.Feature

  describe "new/4" do
    test "returns a Feature struct" do
      expected = %Feature{
        properties: %{a: 1},
        bbox: [0.0, 0.0, 0.0, 0.0],
        geometry: %{
          type: "Foo",
          coordinates: ["bar"]
        }
      }

      actual = Feature.new("Foo", [0.0, 0.0, 0.0, 0.0], %{a: 1}, ["bar"])
      assert actual == expected
    end

    test "returned Feature can be encoded to JSON" do
      feature = Feature.new("", [], %{}, [])
      assert {:ok, _} = Jason.encode(feature)
    end

    test "maps feature type to proper GeoJSON value" do
      feature = Feature.new(:polyline, [], %{}, [])
      assert feature.geometry.type == "LineString"
    end

    test "formats feature type properly" do
      feature = Feature.new(:point, [], %{}, [])
      assert feature.geometry.type == "Point"
    end
  end
end
