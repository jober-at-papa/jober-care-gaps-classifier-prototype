defmodule Scratch.MixProject do
  use Mix.Project

  def project do
    [
      app: :scratch,
      version: "0.1.0",
      elixir: "~> 1.12",
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
      {:csv, "~> 3.0"},
      {:progress_bar, "> 0.0.0"},
      {:bayesic, "~> 0.1.1"},
      {:stout_porter2, "~> 0.1.2"}
    ]
  end
end
