defmodule BigardoneDev.Blog.YamlParser do
  @moduledoc """
  Custom parser to handle YAML frontmatter in markdown files.
  """

  def parse(path, contents) do
    case :binary.split(contents, ["\n---\n", "\r\n---\r\n"]) do
      [frontmatter, body] ->
        {:ok, attrs} = YamlElixir.read_from_string(frontmatter)
        attrs = Map.new(attrs, fn {k, v} -> {String.to_atom(k), v} end)
        {attrs, body}

      [_] ->
        raise "Invalid frontmatter in #{path}"
    end
  end
end
