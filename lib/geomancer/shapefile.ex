defmodule Geomancer.Shapefile do
  alias Geomancer.{Object, Feature}
  alias Exshape.{Shp, Dbf}

  @type geo_json :: String.t()
  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, geo_json()} | {:error, reason()}
  def geo_json(zip_path) do
    [{name, _, shapes}] = Exshape.from_zip(zip_path)

    shapes
    |> features_from_shapes()
    |> object(name)
    |> Jason.encode()
  end

  @spec features_from_shapes([tuple()]) :: [Feature.t()]
  def features_from_shapes([]), do: []

  def features_from_shapes(shapes) do
    {_, _, features} =
      Enum.reduce(shapes, {"", [], []}, fn
        {%Shp.Header{} = shp, %Dbf.Header{} = dbf}, {_, _cs, feats} ->
          type = shp.shape_type |> Atom.to_string() |> String.capitalize()
          {type, Enum.map(dbf.columns, fn c -> c.name end), feats}

      {shape, values}, {type, keys, feats} ->
          properties = for k <- keys, v <- values, do: {k, v}, into: %{}
          [_ | coordinates] = Map.values(shape)
          {type, keys, [Feature.new(type, properties, coordinates) | feats]}
      end)

    Enum.reverse(features)
  end

  @spec object(features :: [Feature.t()], name :: String.t()) :: {:ok, Object.t()}
  defp object(features, name) do

    Object.new(name, features)
  end
end
