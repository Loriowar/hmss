defmodule HMSS.Types.MediaContainer.Info do
  defstruct audio: [],
            video: [],
            subtitle: [],
            duration: 0

  @type t ::
          %__MODULE__{
            audio: list(map()),
            video: list(map()),
            subtitle: list(map()),
            duration: number
          }
end
