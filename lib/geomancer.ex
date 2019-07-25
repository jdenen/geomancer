defmodule Geomancer do
  @moduledoc """
  A behaviour to convert geospatial data from one format to another.
  """

  @type input_path() :: String.t()
  @type conversion() :: String.t()
  @type reason() :: String.t()
  @type geo_struct() :: struct | map

  @callback from(input_path) :: {:ok, conversion} | {:error, reason}
  @callback read(input_path) :: {:ok, geo_struct} | {:error, reason}

  defmacro __using__(_) do
    quote do
      @behaviour Geomancer
    end
  end
end
