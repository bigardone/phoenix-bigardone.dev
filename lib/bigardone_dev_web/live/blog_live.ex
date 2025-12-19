defmodule BigardoneDevWeb.BlogLive do
  @moduledoc false
  use BigardoneDevWeb, :live_view

  alias BigardoneDev.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Articles")
     |> assign(:current_path, "/blog")
     |> assign(:posts, Blog.all_posts())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <section class="mx-auto max-w-6xl px-4 py-12 md:py-32">
        <.section_heading text="Articles" />
        <div class="grid grid-flow-row grid-cols-1 gap-8 md:grid-cols-2">
          <.post_card :for={post <- @posts} post={post} />
        </div>
      </section>
    </Layouts.app>
    """
  end
end
