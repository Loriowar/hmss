defmodule HMSS.Stream.Quality.List do
  def short do
    %HMSS.Types.Quality.List{
      video: [
        %HMSS.Types.Quality.Video{width: 854, height: 480, bitrate: 960_000, framerate: 24}
      ],
      audio: [
        %HMSS.Types.Quality.Audio{channels: 2, bitrate: 96_000}
      ],
      subtitle: [
        %HMSS.Types.Quality.Subtitle{}
      ]
    }
  end

  def full do
    %HMSS.Types.Quality.List{
      video: [
        %HMSS.Types.Quality.Video{width: 480, height: 360, bitrate: 510_000, framerate: 24},
        %HMSS.Types.Quality.Video{width: 854, height: 480, bitrate: 960_000, framerate: 24},
        %HMSS.Types.Quality.Video{width: 1280, height: 720, bitrate: 1725_000, framerate: 24},
        %HMSS.Types.Quality.Video{width: 1920, height: 1080, bitrate: 3400_000, framerate: 24}
      ],
      audio: [
        %HMSS.Types.Quality.Audio{channels: 2, bitrate: 96_000}
      ],
      subtitle: [
        %HMSS.Types.Quality.Subtitle{}
      ]
    }
  end

  def clever(_media_info) do
    #TODO: should build quality based on proportion from initial bitrate and over valuable parameters
  end
end
