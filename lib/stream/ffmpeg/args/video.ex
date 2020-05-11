defmodule HMSS.Stream.FFmpeg.Args.Video do
  import FFmpex
  use FFmpex.Options

  @spec build(String.t, String.t, HLS.Plg.Types.MasterRow.t, Map.t) :: Tuple.t
  def build(input_file_path, output_stream_path, stream_info, timing_data \\ %{limit: 30}) do
    command =
      FFmpex.new_command
      |> add_input_file(input_file_path)
      |> add_output_file(output_playlist_path(output_stream_path, stream_info.details))
      |> add_stream_specifier(stream_type: :video)
      |> add_stream_option(option_b(to_bitrate_format(stream_info)))
      |> add_file_option(option_an())
      |> add_file_option(option_sn())
      |> add_file_option(option_pix_fmt("yuv420p"))
      |> add_file_option(option_vcodec("libx264"))
      |> add_file_option(option_vf(to_scale(stream_info)))
      |> add_file_option(option_force_key_frames("expr:gte(t,n_forced*#{to_target_duration(stream_info.details)})"))
      |> add_file_option(option_sc_threshold(0))
      |> add_file_option(option_r(stream_info.framerate))
      |> add_file_option(option_f("hls"))
      |> add_file_option(option_hls_time(to_target_duration(stream_info.details)))
      |> add_file_option(option_hls_segment_filename(output_segments_path(output_stream_path, stream_info.details)))
      |> add_file_option(option_hls_list_size(99_999))
      |> add_file_option(option_hls_segment_type("mpegts"))

    # TODO: rewrite with conditional pipe
    command =
      if Map.get(timing_data, :limit) != nil do
        command
        |> add_file_option(option_t(timing_data.limit))
      else
        command
      end

    # TODO: rewrite with conditional pipe
    command =
      if Map.get(timing_data, :offset) != nil do
        command
        |> add_file_option(option_ss(timing_data.offset))
        |> add_file_option(option_start_number(segment_start_number(timing_data.offset, stream_info.details.target_duration)))
      else
        command
      end

    prepare(command)
  end

  defp output_playlist_path(initial_path, details) do
    "#{initial_path}#{details.segment_path}dummy.m3u8"
  end

  defp output_segments_path(initial_path, details) do
    "#{initial_path}#{details.segment_path}#{details.segment_basename}%0#{details.segment_number_length |> trunc}d#{details.segment_extension}"
  end

  defp to_bitrate_format(data) do
    "#{data.bandwidth/1000 |> trunc}k"
  end

  defp to_scale(data) do
    "scale=#{data.resolution |> String.replace("x", ":")}"
  end

  defp to_target_duration(details) do
    details.target_duration |> trunc |> Integer.to_string
  end

  # TODO: should be moved to a separate module due to usage in audio and video streams
  @spec segment_start_number(Number.t, Number.t) :: Integer.t
  defp segment_start_number(nil, _target_duration = 10), do: 0
  defp segment_start_number(offset, target_duration = 10) do
    offset / target_duration |> trunc
  end
end
