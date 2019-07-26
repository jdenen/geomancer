defmodule Geomancer do
  @moduledoc false

  @type input_path() :: String.t()
  @type conversion() :: String.t()
  @type reason() :: String.t()
  @type geo_json() :: String.t()
  @type geo_struct() :: Geomancer.Shapefile.t()

  @callback convert(input_path()) :: {:ok, conversion()} | {:error, reason()}
  @callback read(input_path()) :: {:ok, geo_struct() | geo_json()} | {:error, reason()}
  @callback format() :: String.t()

  defmacro __using__(_) do
    quote do
      @behaviour Geomancer

      def convert(_) do
        {:error, "Conversion to #{format()} is unsupported"}
      end

      def read(_) do
        {:error, "Reading #{format()} is unsupported"}
      end

      defoverridable convert: 1, read: 1
    end
  end

  defdelegate geo_json(path), to: Geomancer.GeoJson, as: :convert
end
