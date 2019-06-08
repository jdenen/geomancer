defmodule Geomancer.Shapefile do
  alias Geomancer.{Object, Feature}
  alias Exshape.{Shp, Dbf}

  @type geo_json :: String.t()
  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, geo_json()} | {:error, reason()}
  def geo_json(zip_path) do
    [{name, _, shapes}] = Exshape.from_zip(zip_path)

    shapes
    |> features()
    |> object(name)
    |> Jason.encode()
  end

  @spec features([tuple()]) :: [Feature.t()]
  def features(shapefile) do
    {_, _, features} = Enum.reduce(shapefile, {"", [], []}, &feature_reducer/2)
    Enum.reverse(features)
  end

  @spec feature_reducer(tuple(), tuple()) :: {String.t(), [String.t()], [Feature.t()]}
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
    [_ | coordinates] = Map.values(shape)

    {type, prop_keys, [Feature.new(type, properties, coordinates) | features]}
  end

  @spec parse_properties([String.t()], [term()]) :: map()
  defp parse_properties(keys, values) do
    values
    |> Enum.map(&trim_dbf_value/1)
    |> Enum.zip(keys)
    |> Enum.map(fn {val, key} -> {key, val} end)
    |> Map.new()
  end

  @spec object(features :: [Feature.t()], name :: String.t()) :: Object.t()
  defp object(features, name) do
    Object.new(name, features)
  end

  @spec trim_dbf_value(term()) :: term()
  defp trim_dbf_value(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      val -> val
    end
  end

  defp trim_dbf_value(value), do: value
end
