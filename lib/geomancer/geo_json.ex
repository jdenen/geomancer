defmodule Geomancer.GeoJson do
  @moduledoc false
  use Geomancer
  alias Geomancer.GeoJson.Feature
  alias Exshape.{Shp, Dbf}

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

  @spec new({:ok, struct()} | {:error, String.t()}) :: t() | {:error, String.t()}
  def new({:ok, %Geomancer.Shapefile{} = shapefile}) do
    feature_set = features(shapefile.shp, shapefile.type, shapefile.dbf)
    bbox = [shapefile.bbox.xmin, shapefile.bbox.ymin, shapefile.bbox.xmax, shapefile.bbox.ymax]
    %__MODULE__{features: feature_set, name: shapefile.name, bbox: bbox}
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

  defp features(shapes, type, prop_keys) do
    {_, _, features} = Enum.reduce(shapes, {type, prop_keys, []}, &feature_reducer/2)
    Enum.reverse(features)
  end

  defp feature_reducer({%Shp.Header{}, %Dbf.Header{}}, acc), do: acc

  defp feature_reducer({shape, prop_values}, {type, prop_keys, features}) do
    properties = parse_properties(prop_keys, prop_values)
    coordinates = parse_coordinates(shape)
    bounding_box = parse_bounding_box(shape)

    {type, prop_keys, [Feature.new(type, bounding_box, properties, coordinates) | features]}
  end

  defp parse_properties(keys, values) do
    values
    |> Enum.map(&trim_dbf_value/1)
    |> Enum.zip(keys)
    |> Enum.map(fn {val, key} -> {key, val} end)
    |> Map.new()
  end

  defp parse_coordinates(%{x: x, y: y}), do: [x, y]

  defp parse_coordinates(%{points: [%{x: _, y: _} | _] = points}) do
    points
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates(%{points: [points | _]}) do
    points
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&parse_coordinates/1)
  end

  defp parse_coordinates(points), do: Enum.map(points, &parse_coordinates/1)

  defp parse_bounding_box(%{bbox: %{xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax}}) do
    [xmin, ymin, xmax, ymax]
  end

  defp parse_bounding_box(%{x: x, y: y}), do: [x, y, x, y]

  defp trim_dbf_value(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      val -> val
    end
  end

  defp trim_dbf_value(value), do: value
end
