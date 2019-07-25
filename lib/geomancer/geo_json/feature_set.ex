defmodule Geomancer.GeoJson.FeatureSet do
  @moduledoc false
  alias Geomancer.GeoJson.Feature

  @type t() :: [Feature.t()]

  @spec reduce([Geomancer.geo_struct()], keyword()) :: t()
  def reduce(geometry, opts \\ []) do
    type = Keyword.get(opts, :type, "Point")
    keys = Keyword.get(opts, :properties, [])

    {features, _, _} = Enum.reduce(geometry, {[], type, keys}, &feature_reducer/2)
    Enum.reverse(features)
  end

  defp feature_reducer({%Exshape.Shp.Header{}, _}, acc), do: acc

  defp feature_reducer({shape, values}, {features, type, keys}) do
    props = parse_properties(keys, values)
    coords = parse_coordinates(shape)
    bbox = parse_bounding_box(shape)

    {[Feature.new(type, bbox, props, coords) | features], type, keys}
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

  defp parse_bounding_box(%{bbox: %{xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax}}) do
    [xmin, ymin, xmax, ymax]
  end

  defp parse_bounding_box(%{x: x, y: y}), do: [x, y, x, y]

  defp trim(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      val -> val
    end
  end

  defp trim(value), do: value
end
