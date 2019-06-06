defmodule Geomancer do
  @moduledoc """
  TODO Documentation for Geomancer.
  """

  @type reason :: String.t()

  @spec geo_json(String.t()) :: {:ok, Geomancer.Object.t()} | {:error, reason()}
  def geo_json(input_filepath) do
    case Path.extname(input_filepath) do
      ".zip" ->
        Geomancer.Shapefile.geo_json(input_filepath)

      ext ->
        {:error, "Unsupported format: #{ext}"}
    end
  end
end
