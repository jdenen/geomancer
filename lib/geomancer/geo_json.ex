defmodule Geomancer.GeoJson do
  alias Geomancer.GeoJson.Feature

  @type t :: %__MODULE__{
    type: String.t(),
    name: String.t(),
    features: [Feature.t()]
  }

  @derive Jason.Encoder
  defstruct type: "FeatureCollection",
    features: nil,
    name: nil

  @spec new(name :: String.t(), features :: [Feature.t()]) :: t()
  def new(features, name) do
    %__MODULE__{features: features, name: name}
  end
end
