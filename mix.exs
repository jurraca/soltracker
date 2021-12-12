defmodule SolTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :soltracker,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SolTracker.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:solana, "~> 0.1.3"},
      {:websockex, "~> 0.4.3"},
      {:rustler, "~> 0.22.2"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
