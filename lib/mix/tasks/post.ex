defmodule Mix.Tasks.Post do
  @shortdoc "Generates a new blog post"

  @moduledoc false
  use Mix.Task

  alias Mix.Shell.IO

  @impl Mix.Task
  def run(_) do
    IO.info("")
    IO.info("Creating a new blog post...")
    IO.info("")

    title = IO.prompt("Enter the post title:")
    IO.info("")
    tags = IO.prompt("Enter tags (comma-separated, e.g., elixir, phoenix, liveview):")
    IO.info("")

    IO.info("Generating new post...")
    IO.info("")

    date = Date.to_iso8601(Date.utc_today())
    name = build_name(date, title)

    assigns = %{
      date: date,
      name: name,
      tags: String.trim(tags),
      title: String.trim(title)
    }

    template_dir = template_dir()
    file = Path.join(template_dir, "%name%.md")

    case File.read(file) do
      {:ok, content} ->
        content = EEx.eval_string(content, assigns: assigns)

        relative_path =
          file
          |> Path.relative_to(template_dir)
          |> String.replace("%name%", name)

        file_path =
          Path.join(
            Application.app_dir(:bigardone_dev, "priv/posts"),
            relative_path
          )

        Mix.Generator.create_file(file_path, content)

        IO.info("")
        IO.info("Post created successfully!")

      {:error, error} ->
        IO.info("Error creating new post: #{inspect(error)}")
    end

    IO.info("")
  end

  defp build_name(date, title) do
    title =
      title
      |> String.trim()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\s-]/, "")
      |> String.replace(~r/\s+/, "-")
      |> String.trim("-")

    "#{date}-#{title}"
  end

  defp template_dir do
    Application.app_dir(:bigardone_dev, "priv/templates/post")
  end
end
