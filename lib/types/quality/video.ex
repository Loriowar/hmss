defmodule HMSS.Types.Quality.Video do
  defstruct height: nil,
            width: nil,
            bitrate: nil,
            framerate: 24

  @type t ::
          %__MODULE__{
            height: number,
            width: number,
            bitrate: number,
            framerate: number
          }
end
