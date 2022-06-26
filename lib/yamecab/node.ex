defmodule YAMeCab.Node do
  @moduledoc """
  Struct corresponds to [mecab_node_t](https://taku910.github.io/mecab/doxygen/structmecab__node__t.html).
  """
  defstruct [:surface, :feature, :posid, :stat, :best, :alpha, :beta, :prob, :wcost, :cost]

  @type t :: %__MODULE__{
          surface: binary(),
          feature: binary(),
          posid: non_neg_integer(),
          stat: :nor | :unk | :bos | :eos | :eon,
          best: boolean(),
          alpha: float(),
          beta: float(),
          prob: float(),
          wcost: integer(),
          cost: integer()
        }
end
