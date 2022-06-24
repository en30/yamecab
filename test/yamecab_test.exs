defmodule YAMeCabTest do
  use ExUnit.Case
  doctest YAMeCab

  test "greets the world" do
    assert YAMeCab.hello() == :world
  end
end
