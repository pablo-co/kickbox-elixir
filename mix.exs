defmodule Kickbox.Mixfile do
  use Mix.Project

  @project_url "https://github.com/pablo-co/kickbox-elixir"

  def project do
    [app: :kickbox,
     version: "0.1.0",
     elixir: "~> 1.3",
     source_url: @project_url,
     homepage_url: @project_url,
     name: "Kickbox",
     description: "A Kickbox API client written in Elixir",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :hackney]]
  end

  defp deps do
    [{:cowboy, "~> 1.0", only: [:test, :dev]},
     {:ex_doc, "~> 0.13", only: :dev},
     {:hackney, "~> 1.6"},
     {:plug, "~> 1.0"},
     {:poison, ">= 1.5.0"}]
  end

  defp package do
    [
      maintainers: ["Pablo Cárdenas"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
end
