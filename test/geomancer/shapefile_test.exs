defmodule Geomancer.ShapefileTest do
  use ExUnit.Case
  alias Geomancer.{Shapefile, Feature}

  @headers {
    %Exshape.Shp.Header{shape_type: :foo},
    %Exshape.Dbf.Header{columns: [%{name: "bar"}, %{name: "baz"}]}
  }

  describe "features/1" do
    test "handles an empty list" do
      assert Shapefile.features([]) == []
    end

    test "turns shapes into features" do
      shapefile = [@headers, {%{x: 0.0, y: 1.0}, [1, "a"]}]
      [feature] = Shapefile.features(shapefile)

      assert feature == %Feature{
               type: "Feature",
               properties: %{"bar" => 1, "baz" => "a"},
               geometry: %{type: "Foo", coordinates: [0.0, 1.0]}
             }
    end

    test "trims whitespace from DBF values" do
      shapefile = [@headers, {%{x: 1.0, y: 2.0}, [2, "b    "]}]
      [feature] = Shapefile.features(shapefile)
      assert feature.properties["baz"] == "b"
    end

    test "handles shapes-in-shapes" do
      shape = %{points: [[[%{x: 1.0, y: 2.0}, %{x: 3.0, y: 4.0}]]]}
      [feature] = Shapefile.features([@headers, {shape, [3, "c"]}])

      assert feature == %Feature{
        type: "Feature",
        properties: %{"bar" => 3, "baz" => "c"},
        geometry: %{type: "Foo", coordinates: [[[1.0, 2.0], [3.0, 4.0]]]}
      }
    end
  end
end
