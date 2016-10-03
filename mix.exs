defmodule LQueue.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [app: :lqueue,
     version: @version,
     elixir: "~> 1.3",
     deps: deps(),
     docs: docs(),
     description: description(),
     package: package()]
  end

  def application, do: []

  defp deps do
    [{:dialyxir, "~> 0.3.5", only: :dev},
     {:ex_doc, "~> 0.14", only: :dev}]
  end

  defp docs do
    [source_url: "https://github.com/jur0/lqueue",
     source_ref: "v#{@version}"]
  end

  defp description do
    "Double-ended queue with limited length"
  end

  defp package do
    [maintainers: ["Juraj Hlista"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/jur0/lqueue"}]
  end

end
