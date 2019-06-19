defmodule Geomancer.GeoJson.Feature do
  @moduledoc false
  @type t :: %__MODULE__{
          type: String.t(),
          properties: term(),
          geometry: %{
            type: String.t(),
            coordinates: [term()]
          }
        }

  @derive Jason.Encoder
  defstruct type: "Feature",
            properties: nil,
            geometry: nil

  @spec new(geo_type :: String.t(), props :: map(), coords :: [term()]) :: t()
  def new(geo_type, props, coords) do
    geo = %{type: geo_type, coordinates: coords}
    %__MODULE__{properties: props, geometry: geo}
  end
end
