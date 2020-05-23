defmodule HMSS.Paylist.Writer do
  @spec write(HLS.Plg.Types.All.t, String.t) :: :ok
  def write(playlists, path \\ "./") do
    # TODO: needs to add errors processing
    write_master_playlist(playlists.master, path)
    write_common_playlists(playlists.common, path)

    :ok
  end

  defp write_master_playlist(data, init_path) do
    full_path_for(init_path, "master.m3u8")
    |> File.write(data)
  end

  defp write_common_playlists(data, init_path) do
    write_audio_playlists(data.audio, init_path)
    write_subtitles_playlists(data.subtitles, init_path)
    write_video_playlists(data.video, init_path)
  end

  defp write_audio_playlists(data, init_path), do: common_writer(data, init_path)

  defp write_subtitles_playlists(data, init_path), do: common_writer(data, init_path)

  defp write_video_playlists(data, init_path), do: common_writer(data, init_path)

  defp common_writer(data, init_path) do
    Enum.each(data, fn {path, content} ->
      full_path = full_path_for(init_path, path)
      File.mkdir_p(full_path)

      full_path_for(full_path, "playlist.m3u8")
      |> File.write(content)
    end)
  end

  defp full_path_for(init_path, playlist_path) do
    Path.join(init_path, playlist_path)
  end
end
