defmodule HMSS.Types.Quality.Audio do
  defstruct channels: 2,
            bitrate: nil

  @type t ::
          %__MODULE__{
            channels: number,
            bitrate: number
          }
end
