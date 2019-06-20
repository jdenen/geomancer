defmodule Geomancer.GeoJson do
  @moduledoc false
  alias Geomancer.GeoJson.Feature

  @type t :: %__MODULE__{
          type: String.t(),
          name: String.t(),
          features: [Feature.t()],
          bbox: [float()]
        }

  @derive Jason.Encoder
  defstruct type: "FeatureCollection",
            features: nil,
            name: nil,
            bbox: []

  @spec new(features :: [Feature.t()], name :: String.t(), bbox :: map()) :: t()
  def new(features, name, bbox) do
    bounding = [bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax]
    %__MODULE__{features: features, name: name, bbox: bounding}
  end
end
