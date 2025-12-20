defmodule BigardoneDevWeb.HomeLive do
  @moduledoc false
  use BigardoneDevWeb, :live_view

  alias BigardoneDev.Blog
  alias BigardoneDev.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Home")
     |> assign(:current_path, "/")
     |> stream(:latest_posts, Blog.last_posts(6))
     |> stream_configure(:projects, dom_id: &"project-#{&1.name |> String.downcase() |> String.replace(~r/\s+/, "-")}")
     |> stream(:projects, Projects.all())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <div class="mt-16 md:mt-32">
        <%!-- Hero Section --%>
        <section class="mx-auto w-full max-w-6xl px-4 md:grid md:grid-flow-row md:grid-cols-2 md:gap-4">
          <div class="mb-6 text-xl leading-relaxed text-gray-700 md:mb-0">
            <p class="font-black">
              Hi, how are you doing? I'm Ricardo.
            </p>
            <h1 class="text-purple-1000 my-8 text-4xl font-black">
              I'm a software engineer.
            </h1>
            <p class="mb-6">
              I love building web applications using modern technologies such as <strong>Elixir</strong>, <strong>Phoenix</strong>, and
              <strong>LiveView</strong>
              and sharing my coding experience in this blog.
            </p>
            <p>
              Feel free to read any of my
              <a href="#latest_articles" class="font-black text-purple-700 hover:underline">
                latest articles
              </a>
              or take a look at my <a
                href="#recent_projects"
                class="font-black text-purple-700 hover:underline"
              >
              recent projects</a>.
              I hope you enjoy them.
            </p>
          </div>
          <div class="flex w-auto flex-row justify-center md:justify-end">
            <div class="w-3/4 md:w-auto">
              <img src={~p"/images/bigardone.svg"} width="400" height="400" alt="Ricardo" />
            </div>
          </div>
        </section>

        <%!-- Wave to purple section --%>
        <Layouts.wave_divider color="purple-50" />

        <%!-- Latest Articles Section --%>
        <section class="bg-purple-50" id="latest_articles">
          <div class="mx-auto max-w-6xl px-4">
            <.section_heading text="Latest articles" />
            <div
              id="latest-posts"
              phx-update="stream"
              class="grid grid-flow-row grid-cols-1 gap-8 md:grid-cols-2"
            >
              <.post_card :for={{dom_id, post} <- @streams.latest_posts} id={dom_id} post={post} />
              <div>
                <a
                  href="/blog"
                  class="shadow-custom block rounded-lg bg-purple-200 p-8 text-center font-black text-purple-900 hover:shadow-custom-hover hover:underline"
                >
                  View more articles
                </a>
              </div>
            </div>
          </div>
        </section>

        <%!-- Wave from purple section --%>
        <Layouts.wave_divider color="purple-50" flip={true} />

        <%!-- Projects Section --%>
        <section class="mx-auto max-w-6xl px-4" id="recent_projects">
          <.section_heading text="Recent projects" />
          <div
            id="projects"
            phx-update="stream"
            class="grid grid-flow-row grid-cols-1 gap-8 md:grid-cols-3"
          >
            <.project_card
              :for={{dom_id, project} <- @streams.projects}
              id={dom_id}
              project={project}
            />
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
