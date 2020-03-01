defmodule HMSS.MediaContainer.Info do
  def short(path) when is_bitstring(path) do
    raw_data(path) |> HMSS.MediaContainer.FFprobeExtractor.extract |> Map.merge(%{duration: duration(path)})
  end

  def raw_data(path) do
    {:ok, raw_data} = FFprobe.streams(path)

    raw_data
  end

  def duration(path) do
    FFprobe.duration(path)
  end
end
