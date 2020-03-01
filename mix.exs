defmodule HMSS.MixProject do
  use Mix.Project

  def project do
    [
      app: :hmss,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hls_playlist_generator, git: "https://github.com/Loriowar/hls_playlist_generator.git", branch: "master"},
      {:ffmpex, git: "https://github.com/talklittle/ffmpex.git", tag: "v0.7.1"},
      {:ex_utils, "~> 0.1.7"}
    ]
  end

  defp description do
    "Home Media Server Streamer backend"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["Ivan Zabrovskiy"],
      licenses: ["MIT"],
#      links: %{"GitHub" => "https://github.com/Loriowar/hmss"}
    ]
  end
end
