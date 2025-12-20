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
        name: "bigardone.dev",
        description: "My new website and blog",
        image: "/images/projects/bigardone.jpg",
        repo_url: "https://github.com/bigardone/bigardone.dev",
        project_url: "https://bigardone.dev/",
        tags: ["next.js", "tailwindcss"]
      },
      %{
        name: "Talento IT Blog",
        description: "New static blog for Talento IT",
        image: "/images/projects/blog-talentoit.jpg",
        repo_url: "",
        project_url: "https://blog.talentoit.org/",
        tags: ["next.js", "tailwindcss"]
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
        name: "Elm CSS Patters",
        description: "Common CSS patterns done with elm and elm-css",
        image: "/images/projects/elmcsspatterns.jpg",
        repo_url: "https://github.com/bigardone/elm-css-patterns",
        project_url: "https://elmcsspatterns.io/",
        tags: ["elm", "elm-css", "elm-spa"]
      },
      %{
        name: "Empleo Talento IT",
        description: "Jobs board for Talento IT",
        image: "/images/projects/empleo-talentoit.jpg",
        repo_url: "",
        project_url: "https://empleo.talentoit.org/",
        tags: ["elixir", "phoenix"]
      },
      %{
        name: "Phoenix LiveView Ant Farm",
        description: "Concurrent ant farm with Elixir and Phoenix LiveView",
        image: "/images/projects/phoenix-liveview-ant-farm.jpg",
        repo_url: "https://github.com/bigardone/phoenix-liveview-ant-farm",
        project_url: "https://github.com/bigardone/phoenix-liveview-ant-farm",
        tags: ["elixir", "phoenix", "liveview"]
      },
      %{
        name: "phxsockets.io",
        description: "Phoenix sockets visual client",
        image: "/images/projects/phxsockets.jpg",
        repo_url: "",
        project_url: "http://phxsockets.io/",
        tags: ["elm"]
      },
      %{
        name: "Talento IT",
        description: "Website of Talento IT",
        image: "/images/projects/talentoit.jpg",
        repo_url: "",
        project_url: "https://talentoit.org/",
        tags: ["elixir", "phoenix", "elm"]
      }
    ]
  end
end
