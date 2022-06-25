defmodule Mix.Tasks.Compile.Yamecab do
  def run(_args) do
    {result, _errcode} = System.cmd("make", [], stderr_to_stdout: true)
    IO.binwrite(result)
  end
end

defmodule YAMeCab.MixProject do
  use Mix.Project

  def project do
    [
      app: :yamecab,
      version: "0.1.0",
      elixir: "~> 1.13",
      compilers: [:yamecab] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
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
      {:benchee, "~> 1.1", only: :dev}
    ]
  end
end
