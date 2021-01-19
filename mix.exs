defmodule Matcha.MixProject do
  use Mix.Project

  def project do
    [
      app: :matcha,
      version: "0.1.0",
      elixir: "~> 1.11.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [espec: :test],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :parsetools, :iex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:espec, "~> 1.8.2", only: :test},
    ]
  end
end
