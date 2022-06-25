defmodule YAMeCab.Node do
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
