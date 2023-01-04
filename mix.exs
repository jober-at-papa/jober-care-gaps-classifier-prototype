defmodule Scratch.MixProject do
  use Mix.Project

  def project do
    [
      app: :scratch,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :simple_bayes, :stemmer]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:csv, "~> 3.0"},
      {:simple_bayes, "~> 0.12"},
      {:stemmer, "~> 1.0"},
      {:progress_bar, "> 0.0.0"}
    ]
  end
end
