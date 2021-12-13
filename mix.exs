defmodule Aoc2021.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc2021,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev},
      #      {:matrex, "~> 0.6"},
      {:libgraph, "~> 0.13"},
      {:statistics, "~> 0.6"},
      {:flow, "~> 0.14"},
      {:qex, "~> 0.5"},
      {:memoize, "~> 1.2"},
      {:combine, "~> 0.10.0"},
      {:color_utils, "0.2.0"},
      {:comb, git: "https://github.com/tallakt/comb.git"},
      {:remix, "~> 0.0.1", only: :dev},
      {:rustler, "~> 0.21.1"}
    ]
  end
end
