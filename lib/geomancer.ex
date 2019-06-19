defmodule Geomancer do
  @moduledoc """
  A library to convert between various geospatial file formats
  """

  alias Geomancer.Shapefile

  @type geo_json :: String.t()
  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, geo_json()} | {:error, reason()}
  def geo_json(input_filepath) do
    case Path.extname(input_filepath) do
      ".zip" ->
        Shapefile.geo_json(input_filepath)

      ext ->
        {:error, "Unsupported format: #{ext}"}
    end
  end
end
