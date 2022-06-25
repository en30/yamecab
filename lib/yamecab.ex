defmodule YAMeCab do
  @moduledoc """
  Documentation for `YAMeCab`.
  """

  use GenServer

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Parse a given binary and returns nodes.

  ## Examples

      iex> {:ok, mecab} = YAMeCab.start_link([])
      iex> YAMeCab.parse(mecab, "すもももももももものうち")
      [["すもも", "名詞", "一般", "*", "*", "*", "*", "すもも", "スモモ", "スモモ"], ["も", "助詞", "係助詞", "*", "*", "*", "*", "も", "モ", "モ"], ["もも", "名詞", "一般", "*", "*", "*", "*", "もも", "モモ", "モモ"], ["も", "助詞", "係助詞", "*", "*", "*", "*", "も", "モ", "モ"], ["もも", "名詞", "一般", "*", "*", "*", "*", "もも", "モモ", "モモ"], ["の", "助詞", "連体化", "*", "*", "*", "*", "の", "ノ", "ノ"], ["うち", "名詞", "非自立", "副詞可能", "*", "*", "*", "うち", "ウチ", "ウチ"], ["EOS"], [""]]

  """
  def parse(pid, bin) do
    GenServer.call(pid, {:parse, bin})
  end

  # Server

  @impl GenServer
  def init(state) do
    case load_library() do
      :ok ->
        port = Port.open({:spawn_driver, "yamecab"}, [:binary])
        {:ok, Map.put(state, :port, port)}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl GenServer
  def handle_call({:parse, bin}, _from, state = %{port: port}) do
    Port.command(port, bin)

    receive do
      {^port, {:data, res}} ->
        parsed =
          res
          |> String.split("\n")
          |> Enum.map(&String.split(&1, ~r{[\t,]}))

        {:reply, parsed, state}
    end
  end

  defp load_library do
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
