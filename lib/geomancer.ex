defmodule Geomancer do
  @moduledoc """
  TODO Documentation for Geomancer.
  """

  @type reason :: String.t()

  defmodule Feature do
    @type t :: %__MODULE__{
      type: String.t(),
      properties: term(),
      geometry: %{
        type: String.t(),
        coordinates: [term()]
      }
    }

    defstruct type: "Feature",
              properties: nil,
              geometry: nil

    @spec new(geo_type :: String.t(), props :: map(), coords :: [term()]) :: t()
    def new(geo_type, props, coords) do
      geo = %{type: geo_type, coordinates: coords}
      %__MODULE__{properties: props, geometry: geo}
    end
  end

  defmodule Object do
    alias Geomancer.Feature

    @type t :: %__MODULE__{
            type: String.t(),
            name: String.t(),
            features: [Feature.t()]
          }

    defstruct type: "FeatureCollection",
              name: nil,
              features: nil

    @spec new(name :: String.t(), features :: [Feature.t()]) :: t()
    def new(name, features) do
      %__MODULE__{name: name, features: features}
    end
  end

  defmodule Shapefile do
    alias Geomancer.{Object, Feature}

    @type reason :: String.t()

    @spec geo_json(String.t()) :: {:ok, Object.t()} | {:error, reason()}
    def geo_json(_zip_path) do
      feature = Feature.new("Point", %{}, [10.0, 10.0])
      object = Object.new("MyPoint", [feature])
      {:ok, object}
    end
  end

  @spec geo_json(String.t()) :: {:ok, Geomancer.Object.t()} | {:error, reason()}
  def geo_json(input_filepath) do
    case Path.extname(input_filepath) do
      ".zip"
        -> Geomancer.Shapefile.geo_json(input_filepath)
      ext
        -> {:error, "Unsupported format: #{ext}"}
    end
  end
end
