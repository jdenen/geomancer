defmodule Geomancer.Shapefile do
  @moduledoc false
  alias Geomancer.GeoJson
  alias Exshape.{Shp, Dbf}

  @type geo_json :: String.t()
  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, geo_json()} | {:error, reason()}
  def geo_json(zip_path) do
    [{name, _, shapes}] = Exshape.from_zip(zip_path)
    {type, bbox, columns} = parse_headers(shapes)

    shapes
    |> features(type, columns)
    |> GeoJson.new(name, bbox)
    |> Jason.encode()
  end

  @spec features([tuple()], String.t(), [atom()]) :: [GeoJson.Feature.t()]
  def features(shapes, type, prop_keys) do
    {_, _, features} = Enum.reduce(shapes, {type, prop_keys, []}, &feature_reducer/2)
    Enum.reverse(features)
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

  @spec feature_reducer(tuple(), tuple()) :: {String.t(), [String.t()], [GeoJson.Feature.t()]}
  defp feature_reducer({%Shp.Header{}, %Dbf.Header{}}, acc), do: acc

  defp feature_reducer({shape, prop_values}, {type, prop_keys, features}) do
    properties = parse_properties(prop_keys, prop_values)
    coordinates = parse_coordinates(shape)
    bounding_box = parse_bounding_box(shape)

    {type, prop_keys,
     [GeoJson.Feature.new(type, bounding_box, properties, coordinates) | features]}
  end

  @spec parse_properties([String.t()], [term()]) :: map()
  defp parse_properties(keys, values) do
    values
    |> Enum.map(&trim_dbf_value/1)
    |> Enum.zip(keys)
    |> Enum.map(fn {val, key} -> {key, val} end)
    |> Map.new()
  end

  @spec parse_coordinates(term()) :: list()
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

  defp trim_dbf_value(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      val -> val
    end
  end

  defp trim_dbf_value(value), do: value
end
