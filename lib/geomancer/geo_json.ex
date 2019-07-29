defmodule Geomancer.GeoJson do
  @moduledoc false
  use Geomancer
  alias Geomancer.GeoJson.FeatureSet

  @type geo_json :: String.t()
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
  def convert(input_path) do
    case Path.extname(input_path) do
      ".zip" ->
        input_path
        |> Geomancer.Shapefile.read()
        |> to_geo_json()

      ext ->
        {:error, "Unsupported format: #{ext}"}
    end
  end

  @impl Geomancer
  def read(input_path) do
    case File.read(input_path) do
      {:ok, contents} -> Jason.decode(contents)
      {:error, reason} -> {:error, "Cannot open file '#{input_path}': #{reason}"}
    end
  end

  @impl Geomancer
  def format(), do: "GeoJSON"

  @spec to_geo_json({:ok, struct()} | {:error, String.t()}) ::
          {:ok, geo_json()} | {:error, String.t()}
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
