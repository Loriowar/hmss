defmodule HMSS.Stream.FFmpeg.Video do
  def build_stream(input_file_path) do
    input_file_args = ["-i", input_file_path]
    media_format_args = ~w(-pix_fmt yuv420p -vcodec libx264)
    media_quality_args = ["-an", "-sn", "-vf", "scale=854:480", "-b:v", "510k"]
    partition_args = ["-t", "30"]
    offset_args = [] # ["-ss", "10"]
    stream_segments_args = ~w(-force_key_frames expr:gte\(t,n_forced*10\) -sc_threshold 0 -r 24 -f hls -hls_time 10 -hls_list_size 99999 -start_number 0 -hls_segment_type mpegts streams/video/test.m3u8)

    args = input_file_args ++ media_format_args ++ media_quality_args ++ partition_args ++ offset_args ++ stream_segments_args

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      error -> {:error, error}
    end
  end

  def prepare_stream_dir do
    System.cmd("mkdir", ~w(-p ./streams/video))
  end

  def clear_stream_data do
    System.cmd("rm", ~w(-r ./streams/video))
    prepare_stream_dir()
  end
end
