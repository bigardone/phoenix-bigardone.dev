defmodule BigardoneDev.Projects do
  @moduledoc """
  Static project data for the portfolio section.
  """

  def all do
    [
      %{
        name: "Calendlex",
        description: "Calendly clone with Phoenix LiveView",
        image: "/images/projects/calendlex.jpg",
        repo_url: "https://github.com/bigardone/calendlex",
        project_url: "https://calendlex.herokuapp.com/",
        tags: ["elixir", "phoenix", "liveview", "tailwindcss"]
      },
      %{
        name: "Phoenix CMS",
        description: "Headless CMS fun with Phoenix LiveView and Airtable",
        image: "/images/projects/phoenixcms.jpg",
        repo_url: "https://github.com/bigardone/phoenix-cms",
        project_url: "https://phoenixcms.herokuapp.com/",
        tags: ["elixir", "phoenix", "liveview"]
      },
      %{
        name: "Phoenix LiveView Ant Farm",
        description: "Concurrent ant farm with Elixir and Phoenix LiveView",
        image: "/images/projects/phoenix-liveview-ant-farm.jpg",
        repo_url: "https://github.com/bigardone/phoenix-liveview-ant-farm",
        project_url: "https://github.com/bigardone/phoenix-liveview-ant-farm",
        tags: ["elixir", "phoenix", "liveview"]
      }
    ]
  end
end
