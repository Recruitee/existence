defmodule Existence.MixProject do
  use Mix.Project

  @source_url "https://github.com/Recruitee/existence"
  @version "0.3.0"

  def project do
    [
      app: :existence,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      name: "Existence",
      description: "Asynchronous dependency health checks library"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:plug, "~> 1.10"},
      {:ex_doc, "~> 0.28.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs CHANGELOG.md README.md),
      maintainers: ["Recruitee", "Andrzej Magdziarz"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
