defmodule Geomancer.Shapefile do
  @moduledoc false
  use Geomancer

  @type column :: String.t()
  @type shape ::
          Exshape.Shp.Point
          | Exshape.Shp.PointM
          | Exshape.Shp.PointZ
          | Exshape.Shp.Multipoint
          | Exshape.Shp.MultipointM
          | Exshape.Shp.MultipointZ
          | Exshape.Shp.Polyline
          | Exshape.Shp.PolylineM
          | Exshape.Shp.PolylineZ
          | Exshape.Shp.Polygon
          | Exshape.Shp.PolygonM
          | Exshape.Shp.PolygonZ

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          bbox: map(),
          shp: [shape],
          dbf: [column]
        }

  defstruct [:name, :type, :bbox, :shp, :dbf]

  @impl Geomancer
  def read(input_path) do
    with [{name, _, shapes}] <- Exshape.from_zip(input_path),
         {type, bbox, columns} <- parse_headers(shapes) do
      struct = %__MODULE__{
        name: name,
        type: type,
        bbox: bbox,
        shp: shapes,
        dbf: columns
      }

      {:ok, struct}
    else
      {:error, reason} ->
        {:error, "Cannot parse Shapefile '#{input_path}': #{reason}"}

      error ->
        {:error, inspect(error)}
    end
  end

  @impl Geomancer
  def convert(_) do
    {:error, "Conversion to Shapefile is currently unsupported"}
  end

  defp parse_headers(shapes) do
    {shp, dbf} =
      shapes
      |> Stream.take(1)
      |> Enum.at(0)

    type =
      shp.shape_type
      |> Atom.to_string()
      |> String.capitalize()

    cols = Enum.map(dbf.columns, fn c -> c.name end)

    {type, shp.bbox, cols}
  end
end
