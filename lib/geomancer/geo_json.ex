defmodule Geomancer.GeoJson do
  @moduledoc false
  alias Geomancer.GeoJson.Feature

  @type t :: %__MODULE__{
          type: String.t(),
          name: name(),
          features: [Feature.t()],
          bbox: [float()]
        }

  @typep bbox :: %{xmin: float(), xmax: float(), ymin: float(), ymax: float()}
  @typep name :: String.t()

  @derive Jason.Encoder
  defstruct type: "FeatureCollection",
            features: nil,
            name: nil,
            bbox: []

  @spec new([Feature.t()], name(), bbox()) :: t()
  def new(features, name, %{xmin: x0, xmax: x1, ymin: y0, ymax: y1}) do
    %__MODULE__{features: features, name: name, bbox: [x0, y0, x1, y1]}
  end
end
