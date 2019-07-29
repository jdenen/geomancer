defmodule Geomancer.GeoJson.FeatureSet do
  @moduledoc false
  alias Geomancer.GeoJson.Feature

  @type t() :: [Feature.t()]

  @spec reduce(Geomancer.geo_struct()) :: t()
  def reduce(source) do
    {features, _} = Enum.reduce(source.geometry, {[], source}, &feature_reducer/2)
    Enum.reverse(features)
  end

  defp feature_reducer(%{values: values} = shape, {acc, %Geomancer.Shapefile{} = source}) do
    keys = Enum.map(source.dbf, fn {name, _, _} -> name end)

    props = parse_properties(keys, values)
    coords = parse_coordinates(shape)
    bbox = parse_bbox(shape)

    new_acc = [Feature.new(source.type, bbox, props, coords) | acc]
    {new_acc, source}
  end

  defp parse_properties(keys, values) do
    keys
    |> Enum.zip(values)
    |> Enum.map(fn {key, val} -> {key, trim(val)} end)
    |> Map.new()
  end

  defp parse_coordinates(%{x: x, y: y}), do: [x, y]

  defp parse_coordinates(%{points: [%{x: _, y: _} | _] = points}) do
    points
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates(%{points: [points | _]}) do
    points
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates(points), do: Enum.map(points, &parse_coordinates/1)

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