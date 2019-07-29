defmodule Geomancer.GeoJson.FeatureSet do
  @moduledoc false
  alias Geomancer.GeoJson.Feature

  @type t() :: [Feature.t()]

  @spec map(Geomancer.geo_struct()) :: Enum.t()
  def map(source) do
    Stream.map(source.geometry, &feature_mapper(&1, source))
  end

  defp feature_mapper(%{values: values} = shape, %Geomancer.Shapefile{} = source) do
    keys = Enum.map(source.dbf, fn {name, _, _} -> name end)

    props = parse_properties(keys, values)
    coords = parse_coordinates(shape)
    bbox = parse_bbox(shape)

    Feature.new(source.type, bbox, props, coords)
  end

  defp parse_properties(keys, values) do
    keys
    |> Enum.zip(values)
    |> Enum.map(fn {key, val} -> {key, trim(val)} end)
    |> Map.new()
  end

  defp parse_coordinates(%{x: x, y: y}), do: [x, y]

  defp parse_coordinates(%{points: [%{x: _, y: _} | _] = pts}) do
    pts
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates(%{points: [[%{x: _, y: _} | _] = pts | _]}) do
    Enum.map(pts, &parse_coordinates/1)
  end

  defp parse_coordinates(%{points: [[x | _xs] = pts | _]}) when is_list(x) do
    pts
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates(pts), do: Enum.map(pts, &parse_coordinates/1)

  defp trim(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      val -> val
    end
  end

  defp trim(value), do: value

  defp parse_bbox(%{bbox: bbox}), do: bbox
  defp parse_bbox(%{x: x, y: y}), do: [x, y, x, y]
  defp parse_bbox(_), do: []
end
