defmodule BigardoneDev.Blog.Post do
  @moduledoc """
  Struct representing a blog post with YAML frontmatter.
  """

  @enforce_keys [:id, :title, :date, :excerpt, :body, :path, :reading_time, :tags]

  defstruct [:id, :title, :date, :excerpt, :body, :path, :reading_time, :tags, :image]

  @words_per_minute 250

  def build(filename, attrs, body) do
    # Parse filename: YYYY-MM-DD-slug.md
    [year, month, day | slug_parts] =
      filename
      |> Path.basename(".md")
      |> String.split("-", parts: 4)

    slug = List.last(slug_parts) || Enum.join(slug_parts, "-")
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    path = "/blog/#{year}/#{month}/#{day}/#{slug}"
    reading_time = calculate_reading_time(body)
    tags = parse_tags(attrs[:tags])

    struct!(
      __MODULE__,
      id: slug,
      title: attrs.title,
      date: date,
      excerpt: attrs[:excerpt] || "",
      body: body,
      path: path,
      reading_time: reading_time,
      tags: tags,
      image: attrs[:image]
    )
  end

  defp calculate_reading_time(body) do
    word_count = body |> String.split(~r/\s+/) |> length()
    max(1, ceil(word_count / @words_per_minute))
  end

  defp parse_tags(nil), do: []
  defp parse_tags(tags) when is_binary(tags), do: String.split(tags, ~r/,\s*/)
  defp parse_tags(tags) when is_list(tags), do: tags
end
