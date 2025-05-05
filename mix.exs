defmodule SlackBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_bot,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SlackBot.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:finch, "~> 0.16"},
      {:quantum, "~> 3.5"},
      {:dotenv_parser, "~> 2.0", only: :dev}
    ]
  end
end
