defmodule Geomancer.Wkt do
  @moduledoc false
  use Geomancer

  alias Geomancer.GeoJson

  @impl Geomancer
  def convert(input, :geo_json) do
    with {:ok, geo_json_map} <- GeoJson.parse(input),
         {:ok, geo_struct} <- Geo.JSON.decode(geo_json_map) do
      Geo.WKT.encode(geo_struct)
    else
      {:error, reason} -> {:error, "Unable to convert GeoJSON to #{format()}: #{reason}"}
    end
  end

  def convert(_, source) do
    {:error, "Conversion from #{source} to #{format()} is unsupported"}
  end

  @impl Geomancer
  def format() do
    "Well Known Text"
  end
end
