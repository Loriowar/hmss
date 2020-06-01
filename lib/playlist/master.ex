defmodule HMSS.Paylist.Master do
  @spec generate(HMSS.Types.MediaContainer.Info.t, HMSS.Types.Quality.List.t) :: HLS.Plg.Types.Master.t
  def generate(media_info, qualities) do
    # NOTE: for now, assume that we have only one video in container
    video_info = media_info.video |> List.first

    video_rows =
      qualities.video
      |> Enum.map(fn(el) ->
        %HLS.Plg.Types.MasterRow{
          bandwidth: el.bitrate,
          resolution: resolution_for(el),
          framerate: 24,
          playlist_path: video_playlist_path_for(el, video_info),
          playlist_name: "playlist.m3u8",
          details: %HLS.Plg.Types.Common{
            duration: media_info.duration,
            target_duration: 10,
            sequence_number: 0,
            segment_path: "",
            segment_basename: "segment_",
            segment_number_length: 4,
            segment_extension: ".ts"
          },
          meta: %{
            ffmpeg_index: video_info.ffmpeg_index
          }
        }
      end)

    audio_rows =
      qualities.audio
      |> Enum.map(fn(quality) ->
        media_info.audio
        |> Enum.map(fn(info) ->
          %HLS.Plg.Types.MasterRow{
            language: info.language,
            name: "#{info.title} (#{audio_bitrate_format(quality)})",
            bandwidth: quality.bitrate,
            channels: quality.channels,
            playlist_path: audio_playlist_path_for(quality, info),
            playlist_name: "playlist.m3u8",
            details: %HLS.Plg.Types.Common{
              duration: media_info.duration,
              target_duration: 10,
              sequence_number: 0,
              segment_path: "",
              segment_basename: "segment_",
              segment_number_length: 4,
              segment_extension: ".aac"
            },
            meta: %{
              ffmpeg_index: info.ffmpeg_index,
              sample_rate: info.sample_rate
            }
          }
        end)
      end)
      |> List.flatten

    subtitle_rows =
      qualities.subtitle
      |> Enum.map(fn(quality) ->
        media_info.subtitle
        |> Enum.map(fn(info) ->
           %HLS.Plg.Types.MasterRow{
             language: info.language,
             name: info.title,
             forced: info.forced,
             playlist_path: subtitle_playlist_path_for(quality, info),
             playlist_name: "playlist.m3u8",
             details: %HLS.Plg.Types.Common{
               duration: media_info.duration,
               target_duration: (media_info.duration |> trunc) + 1,
               sequence_number: 0,
               segment_path: "",
               segment_basename: "segment_",
               segment_number_length: 4,
               segment_extension: ".vtt"
             },
             meta: %{
               ffmpeg_index: info.ffmpeg_index
             }
           }
          end)
      end)
      |> List.flatten

    tmp_result = %HLS.Plg.Types.Master{video: video_rows, audio: audio_rows, subtitles: subtitle_rows}

    # below we set proper `sequence_number`
    [video: 0, audio: Enum.count(tmp_result.video), subtitles: Enum.count(tmp_result.video) + Enum.count(tmp_result.audio)]
    |> Enum.reduce(%HLS.Plg.Types.Master{}, fn({stream_type, init_seq_num}, master_acc) ->
      tmp =
        tmp_result
        |> Map.get(stream_type)
        |> Enum.with_index
        |> Enum.reduce([], fn({row, index}, rows_acc) ->
          adjusted_details = Map.merge(row.details, %{sequence_number: init_seq_num + index})
          rows_acc ++ [row |> Map.merge(%{details: adjusted_details})]
        end)

      master_acc |> Map.merge(%{stream_type => tmp})
    end)
  end

  defp resolution_for(quality_data) do
    "#{quality_data.width}x#{quality_data.height}"
  end

  defp video_playlist_path_for(quality_data, _video_data) do
    "video/#{quality_data.height}p/"
  end

  defp audio_bitrate_format(data) do
    "#{data.bitrate/1000 |> trunc}k"
  end

  defp string_to_path_format(str) do
    str |> String.replace(" ", "_") |> String.downcase
  end

  defp audio_playlist_path_for(quality_data, audio_data) do
    # TODO: maybe better to use some index instead of title to simplify a future stream determination while user request
    "audio/#{audio_bitrate_format(quality_data)}/#{audio_data.title |> string_to_path_format}/"
  end

  defp subtitle_playlist_path_for(_quality_data, subtitle_data) do
    # TODO: maybe better to use some index instead of title to simplify a future stream determination while user request
    "sub/#{subtitle_data.title |> string_to_path_format}/"
  end
end
