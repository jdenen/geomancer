defmodule Geomancer.GeoJson do
  @moduledoc false
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

  @spec new(features :: [Feature.t()], name :: String.t()) :: t()
  def new(features, name) do
    %__MODULE__{features: features, name: name}
  end
end
