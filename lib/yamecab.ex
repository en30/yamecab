defmodule YAMeCab do
  @moduledoc """
  Documentation for `YAMeCab`.
  """

  use GenServer

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @spec parse(pid(), binary()) :: list(YAMeCab.Node.t())
  @doc """
  Parse a given binary and returns nodes.

  ## Examples

      iex> {:ok, mecab} = YAMeCab.start_link([])
      iex> YAMeCab.parse(mecab, "すもももももももものうち")
      iex> |> Enum.map(fn n -> {n.surface, n.feature} end)
      [
        {"", "BOS/EOS,*,*,*,*,*,*,*,*"},
        {"すもも", "名詞,一般,*,*,*,*,すもも,スモモ,スモモ"},
        {"も", "助詞,係助詞,*,*,*,*,も,モ,モ"},
        {"もも", "名詞,一般,*,*,*,*,もも,モモ,モモ"},
        {"も", "助詞,係助詞,*,*,*,*,も,モ,モ"},
        {"もも", "名詞,一般,*,*,*,*,もも,モモ,モモ"},
        {"の", "助詞,連体化,*,*,*,*,の,ノ,ノ"},
        {"うち", "名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ"},
        {"", "BOS/EOS,*,*,*,*,*,*,*,*"}
      ]
  """
  def parse(pid, bin) do
    GenServer.call(pid, {:parse, bin})
  end

  # Server

  @impl GenServer
  def init(state) do
    case load_library() do
      :ok ->
        port = Port.open({:spawn_driver, "yamecab"}, [])
        {:ok, Map.put(state, :port, port)}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl GenServer
  def handle_call({:parse, bin}, _from, state = %{port: port}) do
    Port.command(port, bin)

    receive do
      res ->
        {:reply, Enum.map(res, &struct!(YAMeCab.Node, &1)), state}
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
