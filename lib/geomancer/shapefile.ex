defmodule Geomancer.Shapefile do
  alias Geomancer.{Object, Feature}

  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, Object.t()} | {:error, reason()}
  def geo_json(_zip_path) do
    feature = Feature.new("Point", %{}, [10.0, 10.0])
    object = Object.new("MyPoint", [feature])
    {:ok, object}
  end
end
