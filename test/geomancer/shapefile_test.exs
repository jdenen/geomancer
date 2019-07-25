defmodule Geomancer.ShapefileTest do
  use ExUnit.Case
  use Placebo
  doctest Geomancer.Shapefile

  @bbox %{a: "a", b: "b", c: "c"}

  @point {
    %Exshape.Shp.Header{shape_type: :point, bbox: @bbox},
    %Exshape.Dbf.Header{columns: [%{name: "bar"}, %{name: "baz"}]}
  }

  describe "read/1" do
    test "returns ok tuple with structued Shapefile data" do
      shape = {%{x: 0.0, y: 1.0}, [1, "a"]}

      allow Exshape.from_zip(any()), return: [{"test_name", "_", [@point, shape]}]
      expected = expected("test_name", "Point", @bbox, [@point, shape], ["bar", "baz"])

      assert {:ok, actual} = Geomancer.Shapefile.read("ignore.zip")
      assert actual == expected
    end

    test "returns error tuple with reason if Shapefile can't be parsed" do
      assert {:error, "Cannot parse Shapefile 'foo.zip': enoent"} =
               Geomancer.Shapefile.read("foo.zip")

      assert {:error, "Cannot parse Shapefile 'test/support/point.geojson': einval"} =
               Geomancer.Shapefile.read("test/support/point.geojson")
    end
  end

  describe "convert/1" do
    test "is currently unsupported" do
      assert {:error, "Conversion to Shapefile is unsupported"} =
        Geomancer.Shapefile.convert("foo.bar")
    end
  end

  defp expected(name, type, bbox, shp, dbf) do
    %Geomancer.Shapefile{
      name: name,
      type: type,
      bbox: bbox,
      shp: shp,
      dbf: dbf
    }
  end
end
