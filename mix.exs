defmodule Geomancer.MixProject do
  use Mix.Project

  def project do
    [
      app: :geomancer,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_file: {:no_warn, "plt/dialyzer.plt"}]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exshape, "~> 2.2"},
      {:jason, "~> 1.1"},
      {:credo, "~> 0.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:placebo, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.20.2", only: [:dev]}
    ]
  end

  defp aliases() do
    [verify: ["dialyzer", "credo", "format --check-formatted"]]
  end

  defp package do
    [
      maintainers: ["Johnson Denen", "Paul Linville"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/jdenen/geomancer"}
    ]
  end

  defp description() do
    "A library to convert geospatial data from format-to-format: Shapefile, KML, CSV, GeoJSON, etc."
  end

end
