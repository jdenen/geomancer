defmodule Geomancer.ShapefileTest do
  use ExUnit.Case
  use Placebo
  doctest Geomancer.Shapefile

  alias Geomancer.Shapefile

  @bbox %{xmin: "x1", xmax: "x2", ymin: "y1", ymax: "y2"}

  @point {
    %Exshape.Shp.Header{shape_type: :point, bbox: @bbox},
    %Exshape.Dbf.Header{
      columns: [
        %{name: "bar", field_length: 1, field_type: :numeric},
        %{name: "baz", field_length: 2, field_type: :string}
      ]
    }
  }

  describe "parse/1" do
    test "returns ok tuple with structued Shapefile data" do
      pt1 = {%{x: 0.0, y: 1.0}, [1, "a"]}
      pt2 = {%{x: 2.0, y: 3.0}, [2, "b"]}

      allow Exshape.from_zip(any()), return: [{"test_name", "_", [@point, pt1, pt2]}]

      expected = %Shapefile{
        name: "test_name",
        type: :point,
        bbox: ["x1", "y1", "x2", "y2"],
        dbf: [{"bar", :numeric, 1}, {"baz", :string, 2}],
        geometry: [
          %{values: [1, "a"], x: 0.0, y: 1.0},
          %{values: [2, "b"], x: 2.0, y: 3.0}
        ]
      }

      assert {:ok, actual} = Shapefile.parse("ignore.zip")
      assert actual == expected
    end

    test "returns error tuple with reason if Shapefile can't be parsed" do
      assert {:error, "Cannot parse Shapefile 'foo.zip': enoent"} = Shapefile.parse("foo.zip")

      assert {:error, "Cannot parse Shapefile 'test/support/point.geojson': einval"} =
               Shapefile.parse("test/support/point.geojson")
    end
  end

  describe "convert/2" do
    test "is currently unsupported" do
      assert {:error, "Conversion from any to Shapefile is unsupported"} =
               Shapefile.convert("foo.bar", :any)
    end
  end
end
