defmodule HMSS.Stream.FFmpeg.Exec.Simple do
  @spec run(Tuple.t) :: Tuple.t
  def run(args) do
    {binary_path, exec_args} = args
    case System.cmd(binary_path, exec_args, stderr_to_stdout: true) do
      {_, 0} -> {:ok, 0} # in the future, the second element should be a PID of process
      error -> {:error, error}
    end
  end
end
