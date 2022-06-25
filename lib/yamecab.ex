defmodule YAMeCab do
  @moduledoc """
  Documentation for `YAMeCab`.
  """

  @on_load :load_library

  @doc """
  Parse a given binary and returns nodes.

  ## Examples

      iex> YAMeCab.parse("すもももももももものうち")
      [["すもも", "名詞", "一般", "*", "*", "*", "*", "すもも", "スモモ", "スモモ"], ["も", "助詞", "係助詞", "*", "*", "*", "*", "も", "モ", "モ"], ["もも", "名詞", "一般", "*", "*", "*", "*", "もも", "モモ", "モモ"], ["も", "助詞", "係助詞", "*", "*", "*", "*", "も", "モ", "モ"], ["もも", "名詞", "一般", "*", "*", "*", "*", "もも", "モモ", "モモ"], ["の", "助詞", "連体化", "*", "*", "*", "*", "の", "ノ", "ノ"], ["うち", "名詞", "非自立", "副詞可能", "*", "*", "*", "うち", "ウチ", "ウチ"], ["EOS"], [""]]

  """
  def parse(bin) do
    load_library()
    port = Port.open({:spawn_driver, "yamecab"}, [:binary])
    Port.command(port, bin)

    receive do
      {^port, {:data, res}} ->
        res
        |> String.split("\n")
        |> Enum.map(&String.split(&1, ~r{[\t,]}))
    end
  end

  def load_library do
    case :erl_ddll.load("./priv", "yamecab") do
      :ok ->
        :ok

      {:error, :already_loaded} ->
        :ok

      {:error, :permanent} ->
        :ok

      {:error, error} ->
        IO.puts("Can't load yamecab library: #{inspect(:erl_ddll.format_error(error))}")
        {:error, error}
    end
  end
end
