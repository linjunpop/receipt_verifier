defmodule ReceiptVerifier.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :receipt_verifier,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      docs: [
        main: "readme", # The main page in the docs
        extras: ["README.md"]
      ]
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
      {:poison, "~> 2.0 or ~> 3.0"},

      {:dialyxir, "~> 0.3", only: :dev},
      {:exvcr, "~> 0.8", only: :test},

      {:inch_ex, "~> 0.2", only: :docs},
      {:ex_doc, "~> 0.14", only: [:dev, :docs]}
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
        "GitHub" => "https://github.com/linjunpop/receipt_verifier"
      }
    ]
  end
end
