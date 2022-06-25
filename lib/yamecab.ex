defmodule YAMeCab do
  @moduledoc """
  Documentation for `YAMeCab`.
  """

  use GenServer
  alias YAMeCab.ParseError

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @spec parse(pid(), binary()) :: {:ok, list(YAMeCab.Node.t())} | {:error, ParseError.t()}
  @doc """
  Parse a given binary and returns nodes.

  ## Examples

      iex> {:ok, mecab} = YAMeCab.start_link([])
      iex> {:ok, res} = YAMeCab.parse(mecab, "すもももももももものうち")
      iex> Enum.map(res, fn n -> {n.surface, n.feature} end)
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
        try do
          port = Port.open({:spawn_driver, "yamecab"}, [])
          {:ok, Map.put(state, :port, port)}
        rescue
          e in RuntimeError -> {:stop, e.message}
        end

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl GenServer
  def handle_call({:parse, bin}, _from, state = %{port: port}) do
    Port.command(port, bin)

    receive do
      {:ok, res} ->
        {:reply, {:ok, Enum.map(res, &struct!(YAMeCab.Node, &1))}, state}

      {:error, message} ->
        {:reply, {:error, ParseError.exception(message: message)}, state}
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
