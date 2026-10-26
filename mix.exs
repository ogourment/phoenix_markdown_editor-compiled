defmodule Mix.Tasks.Compile.BinaryPhoenixMarkdownEditor do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "LICENSE" => "CFC7749B96F63BD31C3C42B5C471BF756814053E847C10F3EB003417BC523D30",
    "NOTICE" => "B9808F2A3CABCD0CF8F679A970363165A89BBCB622AE3535AD5EC35050E738D2",
    "assets/css/phoenix_markdown_editor.css" =>
      "44B26659DE32B73E7A27022D3C686F9067E8A40D025E2F0A4D40AF1623B56327",
    "assets/js/phoenix_markdown_editor.js" =>
      "EEEBF56457ADB4C2F6A4DD50157A143ACB7631A292374B68E72231961121DFBA",
    "assets/js/vendor/NOTICE.md" =>
      "7401BC067158CE0F7216EFE2C8706EB93360EA34DDC71AB78A352D128B190A69",
    "assets/js/vendor/turndown-LICENSE" =>
      "A055E3A15DB4B4CBB5AF381230EBA085603126D7D5D8C4DAE45EE85B877A9729",
    "ebin/Elixir.PhoenixMarkdownEditor.Component.beam" =>
      "D549AA9377FCF6C73B19B335092F8913497FC9BD7FFCB4CFE103AA7EBAD46A07",
    "ebin/Elixir.PhoenixMarkdownEditor.ContactPicker.beam" =>
      "43DD651198C3C9A14424F4336A115C81DF0774124CD25A80837D77872B71B83F",
    "ebin/Elixir.PhoenixMarkdownEditor.ContactSource.beam" =>
      "23B7D77760C79250BB935040187ED91AFE3D6C4F0B9BA4ACEFCFFADEAC6F1460",
    "ebin/phoenix_markdown_editor.app" =>
      "D04770DE5CF541FDDCE2A22A24343831C74BD9C6B6FDCC3CF270C314C577524D"
  }

  @impl true
  def run(_args) do
    series = Version.parse!(System.version()) |> Map.take([:major, :minor])

    unless series == %{major: 1, minor: 20} and System.otp_release() == "29" do
      Mix.raise(
        "phoenix_markdown_editor requires a binary distribution for Elixir 1.20.x / OTP 29"
      )
    end

    for {path, expected} <- @checksums do
      bytes = File.read!(Path.join(@root, path))

      unless Base.encode16(:crypto.hash(:sha256, bytes)) == expected do
        Mix.raise("phoenix_markdown_editor artifact checksum mismatch: #{path}")
      end

      if String.starts_with?(path, "ebin/") do
        target = Path.join(Mix.Project.compile_path(), Path.basename(path))
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, bytes)
      end
    end

    {:ok, []}
  end
end

defmodule Compiled.PhoenixMarkdownEditor.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_markdown_editor,
      version: "0.1.4",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_markdown_editor],
      deps: [phoenix_live_view: "~> 1.2", phoenix_html: "~> 4.1"]
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
