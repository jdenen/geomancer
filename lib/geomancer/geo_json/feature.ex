defmodule Geomancer.GeoJson.Feature do
  @moduledoc false
  @type t :: %__MODULE__{
          type: String.t(),
          bbox: list(float()),
          properties: term(),
          geometry: %{
            type: String.t(),
            coordinates: [term()]
          }
        }

  @derive Jason.Encoder
  defstruct type: "Feature",
            bbox: nil,
            properties: nil,
            geometry: nil

  @spec new(geo_type :: String.t(), bbox :: list(float()), props :: map(), coords :: [term()]) :: t()
  def new(geo_type, bbox, props, coords) do
    geo = %{type: geo_type, coordinates: coords}
    %__MODULE__{properties: props, bbox: bbox, geometry: geo}
  end
end
