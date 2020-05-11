defmodule HMSS.MediaContainer.FFprobeExtractor do
  def extract(raw_ffmpeg_data) do
    %HMSS.Types.MediaContainer.Info{
      video: extract_and_prettify_data(video_streams(raw_ffmpeg_data), &short_video_data/1),
      audio: extract_and_prettify_data(audio_streams(raw_ffmpeg_data), &short_audio_data/1),
      subtitle: extract_and_prettify_data(subtitle_streams(raw_ffmpeg_data), &short_subtitle_data/1)
    }
  end

  defp video_streams(raw_data) do
    Enum.filter(raw_data, fn (stream_info) -> stream_info["codec_type"] == "video" end)
  end

  defp short_video_data(raw_data) do
    raw_data |> Map.take(~w(height width display_aspect_ratio avg_frame_rate codec_name pix_fmt index))
  end

  defp audio_streams(raw_data) do
    Enum.filter(raw_data, fn (stream_info) -> stream_info["codec_type"] == "audio" end)
  end

  defp short_audio_data(raw_data) do
    raw_data
    |> Map.take(~w(codec_name channels index))
    |> Map.merge(
         %{
           sample_rate: get_sample_rate(raw_data),
           forced: get_forced(raw_data),
           language: get_language(raw_data),
           title: get_full_title(raw_data)
         }
       )
  end

  defp subtitle_streams(raw_data) do
    Enum.filter(raw_data, fn (stream_info) -> stream_info["codec_type"] == "subtitle" end)
  end

  defp short_subtitle_data(raw_data) do
    raw_data
    |> Map.take(~w(codec_name index))
    |> Map.merge(
         %{
           forced: get_forced(raw_data),
           language: get_language(raw_data),
           title: get_full_title(raw_data)
         }
       )
  end

  defp get_language(raw_data) do
    get_in(raw_data, ~w(tags language))
  end

  defp get_title(raw_data) do
    get_in(raw_data, ~w(tags title))
  end

  defp get_full_title(raw_data) do
    "#{get_language(raw_data)} #{get_title(raw_data)}" |> String.trim
  end

  defp get_forced(raw_data) do
    get_in(raw_data, ~w(disposition forced)) == 1 || get_title(raw_data) |> String.downcase == "forced"
  end

  defp get_sample_rate(raw_data) do
    raw_rate = get_in(raw_data, ~w(sample_rate)) |> to_string
    case raw_rate |> Integer.parse do
      {result, _} -> result
      :error -> nil
      _ -> nil
    end
  end

  defp extract_and_prettify_data(list, func) do
    Enum.map(list, fn(el) -> func.(el) |> ExUtils.Map.atomize_keys(deep: true) end)
  end
end
