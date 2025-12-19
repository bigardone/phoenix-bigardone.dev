defmodule BigardoneDev.Blog do
  @moduledoc """
  Blog context with NimblePublisher for compile-time static content.
  """

  use NimblePublisher,
    build: BigardoneDev.Blog.Post,
    from: Application.app_dir(:bigardone_dev, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_js],
    parser: BigardoneDev.Blog.YamlParser

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def all_posts, do: @posts

  def last_posts(count \\ 6), do: Enum.take(@posts, count)

  def get_post_by_path(path) do
    Enum.find(@posts, &(&1.path == path))
  end

  def all_tags, do: @tags
end
