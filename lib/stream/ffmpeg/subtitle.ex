defmodule HMSS.Stream.FFmpeg.Subtitle do
  def build_stream(input_file_path) do
    input_file_args = ["-i", input_file_path]
    stream_selection_args = ["-map", "0:s:1"]
    media_quality_args = ["-an", "-vn", "-scodec", "webvtt"]
    stream_segment_args = ~w(-f segment -segment_list_size 0 -segment_list subs/second/test.m3u8 -segment_format webvtt streams/sub/sub-%d.vtt)

    args = input_file_args ++ stream_selection_args ++ media_quality_args  ++ stream_segment_args

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      error -> {:error, error}
    end
  end

  def prepare_stream_dir do
    System.cmd("mkdir", ~w(-p ./streams/sub))
  end

  def clear_stream_data do
    System.cmd("rm", ~w(-r ./streams/sub))
    prepare_stream_dir()
  end
end
