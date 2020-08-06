defmodule ReceiptVerifier.Mixfile do
  use Mix.Project

  @version "0.11.0"
  @url "https://github.com/linjunpop/receipt_verifier"

  def project do
    [
      app: :receipt_verifier,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      source_url: @url,
      homepage_url: @url,
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :inets]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},
      {:dialyxir, "~> 0.5", only: :dev},
      {:exvcr, "~> 0.8", only: :test},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:inch_ex, "~> 0.5", only: :docs},
      {:ex_doc, "~> 0.15", only: [:dev, :docs]}
    ]
  end

  defp description do
    "Verify iTunes receipt with the App Store"
  end

  defp package do
    [
      name: :receipt_verifier,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Jun Lin"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @url
      }
    ]
  end

  defp docs do
    [
      main: "getting-started",
      extras: [
        "docs/Getting Started.md"
      ]
    ]
  end
end
