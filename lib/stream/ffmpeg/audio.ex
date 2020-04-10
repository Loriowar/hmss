defmodule HMSS.Stream.FFmpeg.Audio do
  def build_stream(input_file_path) do
    input_file_args = ["-i", input_file_path]
    stream_selection_args = ["-map", "0:a:1"]
    media_quality_args = ["-c:a", "aac", "-b:a", "96k", "-ac", "2", "-vn"]
    partition_args = ["-t", "30"]
    offset_args = [] # ["-ss", "10"]
    stream_segment_args = ~w(-f segment -segment_time 10 -segment_list streams/audio/test.m3u8 streams/audio/test%02d.aac)

    args = input_file_args ++ stream_selection_args ++ media_quality_args ++ partition_args ++ offset_args ++ stream_segment_args

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      error -> {:error, error}
    end
  end

  def prepare_stream_dir do
    System.cmd("mkdir", ~w(-p ./streams/audio))
  end

  def clear_stream_data do
    System.cmd("rm", ~w(-r ./streams/audio))
    prepare_stream_dir()
  end
end
