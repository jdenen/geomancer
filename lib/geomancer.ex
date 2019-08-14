defmodule Geomancer do
  @moduledoc false

  @type conversion() :: Geomancer.GeoJson.json()
  @type geo_struct() :: Geomancer.Shapefile.t() | Geomancer.GeoJson.t()

  @type input() :: String.t()
  @type source_format() :: :shapefile
  @type reason() :: String.t()

  @callback convert(input(), source_format()) :: {:ok, conversion()} | {:error, reason()}
  @callback read(input()) :: {:ok, geo_struct()} | {:error, reason()}
  @callback format() :: String.t()

  defmacro __using__(_) do
    quote do
      @behaviour Geomancer

      def convert(_, source_format) do
        {:error, "Conversion from #{source_format} to #{format()} is unsupported"}
      end

      def read(_) do
        {:error, "Reading #{format()} is unsupported"}
      end

      defoverridable convert: 2, read: 1
    end
  end

  defdelegate geo_json(path), to: Geomancer.GeoJson, as: :convert
end
