defmodule ParallelEnum.Mixfile do
  use Mix.Project

  def project do
    [app: :parallel_enum,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: "A parallel enum processing library",
     build_embedded: Mix.env == :prod,
     deps: deps(),
     package: package()]
  end

  defp package do
  [ name: :parallel_enum,
    files: ["lib", "mix.exs", "README.md", "LICENSE*"],
    maintainers: ["Renaud Sauvain"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/exosite/elixir_parallel_enum"}
  ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:earmark, ">= 0.0.0", only: :dev},
    {:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
