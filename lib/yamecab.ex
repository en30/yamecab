defmodule YAMeCab do
  @moduledoc """
  Documentation for `YAMeCab`.
  """

  @on_load :load_library

  @doc """
  Hello world.

  ## Examples

      iex> YAMeCab.hello()
      :world

  """
  def parse(bin) do
    port = Port.open({:spawn_driver, "yamecab"}, [:binary])
    Port.command(port, bin)

    receive do
      {^port, {:data, res}} ->
        res
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
