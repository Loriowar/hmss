defmodule HMSS.Stream.FFmpeg.Args.Audio do
  import FFmpex
  use FFmpex.Options

  @spec build(String.t, String.t, HLS.Plg.Types.MasterRow.t, Map.t) :: Tuple.t
  def build(input_file_path, output_stream_path, stream_info, timing_data \\ %{limit: 30}) do
    command =
      FFmpex.new_command
      |> add_input_file(input_file_path)
      |> add_output_file(output_segments_path(output_stream_path, stream_info.details))
      |> add_stream_specifier(stream_type: :audio)
      |> add_stream_option(option_b(to_audio_bitrate_format(stream_info)))
      |> add_stream_option(option_c(to_extension(stream_info.details)))
      |> add_file_option(option_ac(to_channels(stream_info)))
      |> add_file_option(option_vn())
      |> add_file_option(option_map(to_audio_map(stream_info.meta.ffmpeg_index)))
      |> add_file_option(option_f("segment"))
      |> add_file_option(option_segment_time(to_target_duration(stream_info.details)))
      # Needs to check: is removing of `list` option prevent creation of m3u8 playlist file?
      |> add_file_option(option_segment_list(output_playlist_path(output_stream_path, stream_info.details)))

    # TODO: rewrite with conditional pipe
    command =
      if Map.get(timing_data, :limit) != nil do
        command
        |> add_file_option(option_t(adjusted_duration(timing_data.limit, stream_info.meta.sample_rate)))
      else
        command
      end

    # TODO: rewrite with conditional pipe
    command =
      if Map.get(timing_data, :offset) != nil do
        command
        |> add_file_option(option_ss(timing_data.offset))
        |> add_file_option(option_segment_start_number(segment_start_number(timing_data.offset, stream_info.details.target_duration)))
      else
        command
      end

    prepare(command)
  end

  # http://facta.junis.ni.ac.rs/eae/fu2k93/9murugan.pdf page 374 formula 2
  # https://stackoverflow.com/questions/42609700/converting-aac-stream-to-dash-mp4-with-high-fragment-length-precision
  @spec adjusted_duration(Number.t, nil) :: Float.t
  def adjusted_duration(target_duration, nil) do
    target_duration
  end

  @spec adjusted_duration(Number.t, Integer.t) :: Float.t
  def adjusted_duration(target_duration, sample_rate) do
    time_quant = 1024 / sample_rate
    frames_amount = target_duration / time_quant
    # kind of hack due to uneven distribution of frames in case of multiple audio parts in the result
    # NOTE: maybe, this will leads to audio playback bugs, i.e. to short but annoying disappearing of sound, needs to check
    _expecting_frames_amount = trunc(frames_amount) - 1

    # Float.floor(expecting_frames_amount * time_quant, 2)
    # Actually, only one frame can appear in the last redundant segment, so, enough to slightly decrease total duration
    # this is not 'right', but this leads to a minimal differences between expected and real duration
    Float.floor(target_duration - time_quant, 2)
  end

  # TODO: should be moved to a separate module due to usage in audio and video streams
  @spec segment_start_number(Number.t, Number.t) :: Integer.t
  def segment_start_number(nil, _target_duration = 10), do: 0
  def segment_start_number(offset, target_duration = 10) do
    offset / target_duration |> trunc
  end

  defp output_segments_path(initial_path, details) do
    "#{initial_path}#{details.segment_path}#{details.segment_basename}%0#{details.segment_number_length |> trunc}d#{details.segment_extension}"
  end

  defp output_playlist_path(initial_path, details) do
    "#{initial_path}#{details.segment_path}dummy.m3u8"
  end

  defp to_extension(details) do
    details.segment_extension |> String.replace(".", "")
  end

  defp to_audio_map(stream_number) do
    "0:a:#{stream_number |> trunc}"
  end

  defp to_audio_bitrate_format(data) do
    "#{data.bandwidth/1000 |> trunc}k"
  end

  defp to_target_duration(details) do
    details.target_duration |> trunc |> Integer.to_string
  end

  defp to_channels(data) do
    data.channels |> trunc |> Integer.to_string
  end
end
