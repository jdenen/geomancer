defmodule Geomancer.Shapefile do
  @moduledoc false
  use Geomancer

  defstruct [:name, :type, :bbox, :dbf, :geometry]

  @type column_name() :: String.t()
  @type column_type() :: atom()
  @type column_length() :: integer()
  @type geometry() :: %{
          required(:values) => [any()],
          optional(:points) => [any()],
          optional(:x) => float(),
          optional(:y) => float(),
          optional(:bbox) => [float()]
        }

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          bbox: [float()],
          dbf: [{column_name(), column_type(), column_length()}],
          geometry: [geometry()]
        }

  @impl Geomancer
  def read(input_path) do
    with [{name, _, shapes}] <- Exshape.from_zip(input_path),
         {type, bbox, columns} <- parse_headers(shapes),
         geometries <- parse_geometry(shapes) do
      new(name, type, bbox, columns, geometries)
    else
      {:error, reason} ->
        {:error, "Cannot parse Shapefile '#{input_path}': #{reason}"}

      error ->
        {:error, inspect(error)}
    end
  end

  @impl Geomancer
  def format(), do: "Shapefile"

  defp parse_geometry(shapes) do
    shapes
    |> Enum.reduce([], &shape_reducer/2)
    |> Enum.reverse()
  end

  defp shape_reducer({%{x: x, y: y}, values}, acc) do
    [%{x: x, y: y, values: values} | acc]
  end

  defp shape_reducer({%{bbox: bbox, points: points}, values}, acc) do
    map = %{
      bbox: [bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax],
      points: points,
      values: values
    }

    [map | acc]
  end

  defp shape_reducer(_, acc), do: acc

  defp new(name, type, bbox, dbf, geometry) do
    struct = %__MODULE__{
      name: name,
      type: type,
      bbox: bbox,
      dbf: dbf,
      geometry: geometry
    }

    {:ok, struct}
  end

  defp parse_headers(shapes) do
    {%{bbox: bbox} = shp, dbf} =
      shapes
      |> Stream.take(1)
      |> Enum.at(0)

    cols = Enum.map(dbf.columns, fn c -> {c.name, c.field_type, c.field_length} end)

    {shp.shape_type, [bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax], cols}
  end
end
