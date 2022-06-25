defmodule YAMeCab.ParseError do
  defexception [:message]

  @type t :: %__MODULE__{
          __exception__: true,
          message: binary()
        }
end
