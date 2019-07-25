defmodule Geomancer.GeoJson do
  @moduledoc false
  use Geomancer
  alias Geomancer.GeoJson.FeatureSet

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

  @spec new({:ok, struct()} | {:error, String.t()}) :: t() | {:error, String.t()}
  def new({:ok, %Geomancer.Shapefile{} = shapefile}) do
    features = FeatureSet.reduce(shapefile.shp, type: shapefile.type, properties: shapefile.dbf)
    bbox = [shapefile.bbox.xmin, shapefile.bbox.ymin, shapefile.bbox.xmax, shapefile.bbox.ymax]
    %__MODULE__{features: features, name: shapefile.name, bbox: bbox}
  end

  def new({:error, _} = error), do: error

  @impl Geomancer
  def from(input_path) do
    case Path.extname(input_path) do
      ".zip" ->
        input_path
        |> Geomancer.Shapefile.read()
        |> new()
        |> Jason.encode()

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
end
