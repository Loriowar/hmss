defmodule HMSS.Types.Quality.Subtitle do
  defstruct void: nil

  @type t ::
          %__MODULE__{
            void: integer
          }
end
