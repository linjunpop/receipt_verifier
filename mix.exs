defmodule ReceiptVerifier.Mixfile do
  use Mix.Project

  @version "0.13.0"
  @url "https://github.com/linjunpop/receipt_verifier"

  def project do
    [
      app: :receipt_verifier,
      version: @version,
      elixir: "~> 1.4",
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
    [
      extra_applications: [:logger],
      env: [json_library: Jason]
    ]
  end

  defp deps do
    [
      {:hackney, "~> 1.14"},
      {:jason, "~> 1.0", optional: true},
      {:dialyxir, "~> 0.5", only: :dev},
      {:exvcr, "~> 0.8", only: :test},
      {:credo, "~> 0.10", only: [:dev, :test]},
      {:inch_ex, "~> 1.0", only: [:dev, :test, :docs]},
      {:ex_doc, "~> 0.19", only: [:dev, :docs]}
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
