defmodule Geomancer.Shapefile do
  alias Geomancer.GeoJson
  alias Exshape.{Shp, Dbf}

  @type geo_json :: String.t()
  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, geo_json()} | {:error, reason()}
  def geo_json(zip_path) do
    [{name, _, shapes}] = Exshape.from_zip(zip_path)

    shapes
    |> features()
    |> GeoJson.new(name)
    |> Jason.encode()
  end

  @spec features([tuple()]) :: [GeoJson.Feature.t()]
  def features(shapes) do
    {_, _, features} = Enum.reduce(shapes, {"", [], []}, &feature_reducer/2)
    Enum.reverse(features)
  end

  @spec feature_reducer(tuple(), tuple()) :: {String.t(), [String.t()], [GeoJson.Feature.t()]}
  defp feature_reducer({%Shp.Header{} = shp, %Dbf.Header{} = dbf}, {_, _, features}) do
    cols = Enum.map(dbf.columns, fn c -> c.name end)

    type =
      shp.shape_type
      |> Atom.to_string()
      |> String.capitalize()

    {type, cols, features}
  end

  defp feature_reducer({shape, prop_values}, {type, prop_keys, features}) do
    properties = parse_properties(prop_keys, prop_values)
    coordinates = parse_coordinates(shape)

    {type, prop_keys, [GeoJson.Feature.new(type, properties, coordinates) | features]}
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
  def parse_coordinates(%{x: x, y: y}), do: [x, y]

  def parse_coordinates(%{points: [%{x: _, y: _} | _] = point}) do
    point
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&parse_coordinates/1)
  end

  def parse_coordinates(%{points: [polygon | _]}) do
    polygon
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&parse_coordinates/1)
  end

  def parse_coordinates(points), do: Enum.map(points, &parse_coordinates/1)

  defp trim_dbf_value(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      val -> val
    end
  end

  defp trim_dbf_value(value), do: value
end
