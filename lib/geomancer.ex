defmodule Geomancer do
  @moduledoc false

  @type input_path() :: String.t()
  @type conversion() :: String.t()
  @type reason() :: String.t()
  @type geo_struct() :: struct | map

  @callback convert(input_path) :: {:ok, conversion} | {:error, reason}
  @callback read(input_path) :: {:ok, geo_struct} | {:error, reason}

  defmacro __using__(_) do
    quote do
      @behaviour Geomancer
    end
  end

  defdelegate geo_json(path), to: Geomancer.GeoJson, as: :convert
end
