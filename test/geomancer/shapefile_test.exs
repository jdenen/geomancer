defmodule Geomancer.ShapefileTest do
  use ExUnit.Case
  alias Geomancer.{Shapefile, Feature}

  @shapes [
    {%Exshape.Shp.Header{
       bbox: %Exshape.Shp.Bbox{
         mmax: 0.0,
         mmin: 0.0,
         xmax: 10.0,
         xmin: 0.0,
         ymax: 10.0,
         ymin: 5.0,
         zmax: 0.0,
         zmin: 0.0
       },
       shape_type: :point
     },
     %Exshape.Dbf.Header{
       columns: [
         %Exshape.Dbf.Column{
           field_length: 5,
           field_type: :numeric,
           name: "pointId"
         },
         %Exshape.Dbf.Column{
           field_length: 5,
           field_type: :numeric,
           name: "letter"
         }
       ],
       header_byte_count: 65,
       last_updated: {2019, 7, 4},
       record_byte_count: 6,
       record_count: 3
     }},
    {%Exshape.Shp.Point{x: 0.0, y: 10.0}, [1, "a"]},
    {%Exshape.Shp.Point{x: 10.0, y: 10.0}, [2, "b"]},
    {%Exshape.Shp.Point{x: 5.0, y: 5.0}, [3, "c"]}
  ]

  describe "features_from_shapes/1" do
    test "returns empty list when given no shapes" do
      assert Shapefile.features_from_shapes([]) == []
    end

    test "returns a list of features when given a list of shape tuples" do
      features = Shapefile.features_from_shapes(@shapes)

      assert List.first(features) == %Feature{
               type: "Feature",
               properties: %{
                 "pointId" => 1,
                 "letter" => "a"
               },
               geometry: %{
                 type: "Point",
                 coordinates: [
                   0.0,
                   10.0
                 ]
               }
             }
    end
  end
end
