defmodule HMSS.Types.Quality.Unit do
  defstruct audio: nil,
            video: nil,
            subtitle: %HMSS.Types.Quality.Subtitle{}

  @type t ::
          %__MODULE__{
            audio: HMSS.Types.Quality.Audio.t,
            video: HMSS.Types.Quality.Video.t,
            subtitle: HMSS.Types.Quality.Subtitle.t,
          }
end
