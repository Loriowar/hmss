defmodule HMSS.MediaContainer.Info do
  def short(path) when is_bitstring(path) do
    raw_data(path)
    |> HMSS.MediaContainer.FFprobeExtractor.extract
    |> set_ffmpeg_stream_index
    |> Map.merge(%{duration: duration(path)})
  end

  def raw_data(path) do
    {:ok, raw_data} = FFprobe.streams(path)

    raw_data
  end

  def duration(path) do
    FFprobe.duration(path)
  end

  # setup internal index started from zero within each type of stream
  defp set_ffmpeg_stream_index(short_data) do
    [:video, :audio, :subtitle]
    |> Enum.reduce(
         %{},
         fn(media_type, result) ->
           min_index =
             short_data[media_type]
             |> Enum.map(fn(el) -> el[:index] end)
             |> Enum.reject(&is_nil/1)
             |> Enum.min

           new_media_type =
             short_data[media_type]
             |> Enum.map(
                  fn(el)->
                    Map.merge(
                      el,
                      %{ffmpeg_index: el[:index] - min_index})
                  end
                )

           result |> Map.merge(%{media_type => new_media_type})
         end
       )
  end
end
