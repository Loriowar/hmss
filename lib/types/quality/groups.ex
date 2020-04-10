defmodule HMSS.Types.Quality.Groups do
  defstruct units: []

  @type t ::
          %__MODULE__{
            units: [HMSS.Types.Quality.Unit.t]
          }
end
