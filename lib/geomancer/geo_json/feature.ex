defmodule Geomancer.GeoJson.Feature do
  @moduledoc false

  @type_map %{
    polyline: "LineString"
  }

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

  @spec new(geo_type :: String.t(), bbox :: list(float()), props :: map(), coords :: [term()]) ::
          t()
  def new(geo_type, bbox, props, coords) do
    type = Map.get(@type_map, geo_type, geo_type)
    geo = %{type: format_type(type), coordinates: coords}
    %__MODULE__{properties: props, bbox: bbox, geometry: geo}
  end

  defp format_type(type) when is_atom(type) do
    type
    |> Atom.to_string()
    |> String.capitalize()
  end

  defp format_type(type), do: type
end
