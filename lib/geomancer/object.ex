defmodule Geomancer.Object do
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
