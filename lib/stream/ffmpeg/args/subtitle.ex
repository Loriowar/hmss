defmodule HMSS.Stream.FFmpeg.Args.Subtitle do
  import FFmpex
  use FFmpex.Options

  @spec build(String.t, String.t, HLS.Plg.Types.MasterRow.t, Map.t) :: Tuple.t
  def build(input_file_path, output_stream_path, stream_info, _timing_data \\ %{}) do
    command =
      FFmpex.new_command
      |> add_input_file(input_file_path)
      |> add_output_file(output_segments_path(output_stream_path, stream_info.details))
      |> add_stream_specifier(stream_type: :subtitle)
      |> add_file_option(option_vn())
      |> add_file_option(option_an())
      |> add_file_option(option_map(to_subtitle_map(stream_info.meta.ffmpeg_index)))
      |> add_file_option(option_scodec("webvtt"))
      |> add_file_option(option_f("segment"))
      |> add_file_option(option_segment_format("webvtt"))
      |> add_file_option(option_segment_list(output_playlist_path(output_stream_path, stream_info.details)))
      |> add_file_option(option_segment_list_size(0))

    prepare(command)
  end

  defp output_segments_path(initial_path, details) do
    "#{initial_path}#{details.segment_path}#{details.segment_basename}%0#{details.segment_number_length |> trunc}d#{details.segment_extension}"
  end

  defp to_subtitle_map(stream_number) do
    "0:s:#{stream_number |> trunc}"
  end

  defp output_playlist_path(initial_path, details) do
    "#{initial_path}#{details.segment_path}dummy.m3u8"
  end
end
