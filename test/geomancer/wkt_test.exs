defmodule Geomancer.WktTest do
  use ExUnit.Case
  doctest Geomancer.Wkt

  alias Geomancer.Wkt

  @point ~s|{
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Point",
        "coordinates": [72.0703125, 49.83798245308484]
      }
    }|

  @line ~s|{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "LineString",
      "coordinates": [
        [55.8984375, 35.31736632923788],
        [81.73828125, 37.579412513438385]
      ]
    }
  }|

  @simple ~s|{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "Polygon",
      "coordinates": [
        [
          [-8.734130859375, 53.76819584019795],
          [-8.54736328125, 53.29805557491275],
          [-7.723388671875, 53.57946149373232],
          [-8.734130859375, 53.76819584019795]
        ]
      ]
    }
  }|

  @polygon ~s|{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "Polygon",
      "coordinates": [
        [
          [-8.734130859375, 53.76819584019795],
          [-8.54736328125, 53.29805557491275],
          [-7.723388671875, 53.57946149373232],
          [-8.734130859375, 53.76819584019795]
        ],
        [
          [-8.525390625, 53.585983654559826],
          [-8.360595703125, 53.461890432859114],
          [-8.26171875, 53.585983654559826],
          [-8.525390625, 53.585983654559826]
        ]
      ]
    }
  }|

  describe "convert/2" do
    test "converts GeoJSON point to WKT" do
      assert {:ok, "POINT(72.0703125 49.83798245308484)"} = Wkt.convert(@point, :geo_json)
    end

    test "converts GeoJSON line to WKT" do
      expected = "LINESTRING(55.8984375 35.31736632923788,81.73828125 37.579412513438385)"
      assert {:ok, ^expected} = Wkt.convert(@line, :geo_json)
    end

    test "converts GeoJSON polygon (without holes) to WKT" do
      expected =
        "POLYGON((-8.734130859375 53.76819584019795,-8.54736328125 53.29805557491275,-7.723388671875 53.57946149373232,-8.734130859375 53.76819584019795))"

      assert {:ok, ^expected} = Wkt.convert(@simple, :geo_json)
    end

    test "converts GeoJSON polygon (with holes) to WKT" do
      expected =
        "POLYGON((-8.734130859375 53.76819584019795,-8.54736328125 53.29805557491275,-7.723388671875 53.57946149373232,-8.734130859375 53.76819584019795),(-8.525390625 53.585983654559826,-8.360595703125 53.461890432859114,-8.26171875 53.585983654559826,-8.525390625 53.585983654559826))"

      assert {:ok, ^expected} = Wkt.convert(@polygon, :geo_json)
    end

    test "converts GeoJSON FeatureCollection to list of WKT" do
      features = ~s|{"type": "FeatureCollection", "features": [#{@point}, #{@line}, #{@simple}]}|

      expected =
        "GEOMETRYCOLLECTION(POINT(72.0703125 49.83798245308484),LINESTRING(55.8984375 35.31736632923788,81.73828125 37.579412513438385),POLYGON((-8.734130859375 53.76819584019795,-8.54736328125 53.29805557491275,-7.723388671875 53.57946149373232,-8.734130859375 53.76819584019795)))"

      assert {:ok, ^expected} = Wkt.convert(features, :geo_json)
    end

    test "returns error tuple for unsupported conversions" do
      assert Wkt.convert("foo", :bar) ==
               {:error, "Conversion from bar to Well Known Text is unsupported"}
    end
  end

  describe "format/0" do
    test "returns format name" do
      assert Wkt.format() == "Well Known Text"
    end
  end
end
