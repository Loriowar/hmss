defmodule HMSS.Types.Playlist.Precursor do
  defstruct qualities: %HMSS.Types.Quality.List{},
            media_data: []

  @type t ::
          %__MODULE__{
            qualities: HMSS.Types.Quality.List.t,
            media_data: HMSS.Types.MediaContainer.Info.t
          }
end
