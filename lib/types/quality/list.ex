defmodule HMSS.Types.Quality.List do
  defstruct audio: [],
            video: [],
            subtitle: []

  @type t ::
          %__MODULE__{
            audio: [HMSS.Types.Quality.Audio.t],
            video: [HMSS.Types.Quality.Video.t],
            subtitle: [HMSS.Types.Quality.Subtitle.t],
          }
end
