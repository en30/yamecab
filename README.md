# YAMeCab

[![CI](https://github.com/en30/yamecab/actions/workflows/ci.yml/badge.svg)](https://github.com/en30/yamecab/actions/workflows/ci.yml)
[Docs](https://hexdocs.pm/yamecab)

<!-- MDOC !-->

Yet Another Elixir binding for [MeCab](https://taku910.github.io/mecab).

YAMeCab is implemented in [Port Drivers](https://www.erlang.org/doc/tutorial/c_portdriver.html). So it is fast but possibly crashes Erlang VM.

## Installation

The package can be installed by adding `yamecab` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yamecab, "~> 0.1.0"}
  ]
end
```

<!-- MDOC !-->

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/yamecab>.
