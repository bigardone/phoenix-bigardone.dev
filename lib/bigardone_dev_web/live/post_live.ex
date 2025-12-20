defmodule BigardoneDevWeb.PostLive do
  @moduledoc false
  use BigardoneDevWeb, :live_view

  alias BigardoneDev.Blog

  @impl true
  def mount(%{"year" => year, "month" => month, "day" => day, "slug" => slug}, _session, socket) do
    path = "/blog/#{year}/#{month}/#{day}/#{slug}"

    case Blog.get_post_by_path(path) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Post not found")
         |> redirect(to: "/blog")}

      post ->
        {:ok,
         socket
         |> assign(:page_title, post.title)
         |> assign(:current_path, path)
         |> assign(:post, post)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <section class="prose prose-purple mx-auto mt-16 max-w-none px-4 md:prose-lg md:mt-32 md:max-w-4xl">
        <header class="mb-10">
          <h1 class="mb-4 font-bold">{@post.title}</h1>
          <div class="mb-4 text-xl text-gray-500">{@post.excerpt}</div>
          <.post_meta date={@post.date} reading_time={@post.reading_time} tags={@post.tags} />
        </header>
        <article class="mb-16">
          {raw(@post.body)}
        </article>
      </section>
    </Layouts.app>
    """
  end
end
