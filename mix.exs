defmodule YAMeCab.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/en30/yamecab"

  def project do
    [
      app: :yamecab,
      name: "YAMeCab",
      version: @version,
      elixir: "~> 1.12",
      compilers: [:yamecab] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:benchee, "~> 1.1", only: :dev}
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "compile --warnings-as-errors"
      ]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "YAMeCab"
    ]
  end

  defp package do
    [
      description: "Yet Another Elixir binding for MeCab implemented in Port Drivers",
      maintainers: ["en30"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      exclude_patterns: [
        ~r"priv/.*?\.so",
        ~r"priv/.*?\.benchee"
      ]
    ]
  end
end

defmodule Mix.Tasks.Compile.Yamecab do
  def run(_args) do
    File.mkdir("priv")
    {result, code} = System.cmd("make", [], stderr_to_stdout: true)

    if code == 0 do
      {:ok, []}
    else
      IO.binwrite(result)
      {:error, ["exit code #{code}"]}
    end
  end
end
