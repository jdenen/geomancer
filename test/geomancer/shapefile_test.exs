defmodule Geomancer.ShapefileTest do
  use ExUnit.Case
  alias Geomancer.{Shapefile, GeoJson}

  @point {
    %Exshape.Shp.Header{shape_type: :point},
    %Exshape.Dbf.Header{columns: [%{name: "bar"}, %{name: "baz"}]}
  }

  @polygon {
    %Exshape.Shp.Header{shape_type: :polygon},
    %Exshape.Dbf.Header{columns: [%{name: "foo"}]}
  }

  describe "features/1" do
    test "handles an empty list" do
      assert Shapefile.features([]) == []
    end

    test "converts point into features" do
      shapefile = [@point, {%{x: 0.0, y: 1.0}, [1, "a"]}]
      [feature] = Shapefile.features(shapefile)

      assert feature == %GeoJson.Feature{
               type: "Feature",
               properties: %{"bar" => 1, "baz" => "a"},
               geometry: %{type: "Point", coordinates: [0.0, 1.0]}
             }
    end

    test "converts independent points into features" do
      shapefile = [@point, {%{x: 0.0, y: 1.0}, [1, "a"]}, {%{x: 2.0, y: 3.0}, [2, "b"]}]
      [p1 | [p2 | _]] = Shapefile.features(shapefile)

      assert p1.geometry.coordinates == [0.0, 1.0]
      assert p2.geometry.coordinates == [2.0, 3.0]
    end

    test "converts a polygon into features" do
      outer = [
        %{x: 1.0, y: 2.0},
        %{x: 2.0, y: 2.0},
        %{x: 2.0, y: 3.0},
        %{x: 1.0, y: 2.0}
      ]

      shapefile = [@polygon, {%{points: [[outer]]}, [0]}]
      [feature] = Shapefile.features(shapefile)

      assert feature == %GeoJson.Feature{
               type: "Feature",
               properties: %{"foo" => 0},
               geometry: %{
                 type: "Polygon",
                 coordinates: [
                   [
                     [1.0, 2.0],
                     [2.0, 3.0],
                     [2.0, 2.0],
                     [1.0, 2.0]
                   ]
                 ]
               }
             }
    end

    test "converts a polygon with a hole into features" do
      outer = [
        %{x: 0.0, y: 0.0},
        %{x: -4.0, y: 0.0},
        %{x: -4.0, y: -4.0},
        %{x: 0.0, y: -4.0},
        %{x: 0.0, y: 0.0}
      ]

      inner = [
        %{x: -1.0, y: -1.0},
        %{x: -1.0, y: -2.0},
        %{x: -2.0, y: -2.0},
        %{x: -1.0, y: -1.0},
      ]

      shapefile = [@polygon, {%{points: [[outer, inner]]}, [0]}]
      [feature] = Shapefile.features(shapefile)

      assert feature == %GeoJson.Feature{
        type: "Feature",
        properties: %{"foo" => 0},
        geometry: %{
          type: "Polygon",
          coordinates: [
            [
              [0.0, 0.0],
              [0.0, -4.0],
              [-4.0, -4.0],
              [-4.0, 0.0],
              [0.0, 0.0]
            ],
            [
              [-1.0, -1.0],
              [-2.0, -2.0],
              [-1.0, -2.0],
              [-1.0, -1.0]
            ]
          ]
        }
      }
    end

    test "trims whitespace from DBF values" do
      shapefile = [@point, {%{x: 1.0, y: 2.0}, [2, "b    "]}]
      [feature] = Shapefile.features(shapefile)
      assert feature.properties["baz"] == "b"
    end
  end
end
