defmodule Geomancer.Feature do
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
