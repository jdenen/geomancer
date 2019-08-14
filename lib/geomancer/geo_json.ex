defmodule Geomancer.GeoJson do
  @moduledoc false
  use Geomancer

  alias Geomancer.Shapefile
  alias Geomancer.GeoJson.FeatureSet

  @type json :: String.t()
  @type t :: %__MODULE__{
          type: String.t(),
          name: String.t(),
          features: FeatureSet.t(),
          bbox: [float()]
        }

  @derive Jason.Encoder
  defstruct type: "FeatureCollection",
            features: nil,
            name: nil,
            bbox: []

  @impl Geomancer
  def convert(input, source \\ :shapefile)

  def convert(input, :shapefile) do
    input
    |> Shapefile.read()
    |> to_geo_json()
  end

  def convert(_, source) do
    {:error, "Conversion from #{source} to GeoJSON is unsupported"}
  end

  @impl Geomancer
  def read(input) do
    Jason.decode(input)
  end

  @impl Geomancer
  def format(), do: "GeoJSON"

  @spec to_geo_json({:ok, struct()} | {:error, String.t()}) ::
          {:ok, json()} | {:error, String.t()}
  defp to_geo_json({:ok, source}) do
    source
    |> new()
    |> Jason.encode()
  end

  defp to_geo_json({:error, _} = error), do: error

  @spec new(Geomancer.geo_struct()) :: t()
  defp new(%{bbox: bbox} = source) do
    features =
      source
      |> FeatureSet.map()
      |> Enum.to_list()

    %__MODULE__{features: features, name: source.name, bbox: bbox}
  end
end
