defmodule Geomancer.Shapefile.Coordinates do

  @spec parse(term()) :: list() | nil
  def parse(%{x: x, y: y}), do: [x, y]

  def parse(coords) when is_list(coords) do
    coords
    |> Enum.map(&parse/1)
    |> Enum.map(&unwrap/1)
    |> Enum.reject(&nil?/1)
  end

  def parse(coords) when is_map(coords) do
    coords
    |> Map.values()
    |> Enum.flat_map(&parse/1)
    |> Enum.map(&unwrap/1)
    |> Enum.reject(&nil?/1)
  end

  def parse(_), do: [nil]

  defp unwrap([points]) when is_list(points), do: points
  defp unwrap(points), do: points

  defp nil?(nil), do: true
  defp nil?([nil]), do: true
  defp nil?(_), do: false
end
