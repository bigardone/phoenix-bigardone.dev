defmodule BigardoneDevWeb.BlogComponents do
  @moduledoc false
  use Phoenix.Component

  attr :text, :string, required: true

  def section_heading(assigns) do
    ~H"""
    <div class="text-purple-1000 mb-16 text-3xl font-black">
      <span class="inline-block py-6">
        {@text}
      </span>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :post, :map, required: true

  def post_card(assigns) do
    ~H"""
    <article
      id={@id}
      class="shadow-custom cursor-pointer rounded-lg bg-white p-8 transition-shadow duration-300 hover:shadow-custom-hover"
    >
      <.link navigate={@post.path}>
        <header class="mb-5">
          <h2 class="mb-6 text-xl font-black hover:text-purple-900 hover:underline">
            {@post.title}
          </h2>
          <h3 class="text-base text-gray-500">{@post.excerpt}</h3>
        </header>
        <div class="inline-block text-xs">
          <.post_meta date={@post.date} reading_time={@post.reading_time} tags={@post.tags} />
        </div>
      </.link>
    </article>
    """
  end

  attr :date, Date, required: true
  attr :reading_time, :integer, required: true
  attr :tags, :list, default: []

  def post_meta(assigns) do
    ~H"""
    <div class="text-sm text-gray-500">
      {format_date(@date)} &middot; {@reading_time} min read <.tags tags={@tags} />
    </div>
    """
  end

  attr :tags, :list, default: []

  def tags(assigns) do
    ~H"""
    <div class="mt-2 flex flex-wrap text-xs">
      <div :for={tag <- @tags} class="mr-2 mb-2 rounded-md bg-gray-100 p-2">
        {tag}
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :project, :map, required: true

  def project_card(assigns) do
    ~H"""
    <article
      id={@id}
      class="shadow-custom relative rounded-lg border border-gray-100 bg-white transition-shadow duration-300 hover:shadow-custom-hover"
    >
      <div class="relative h-44 overflow-hidden rounded-t-lg bg-purple-400">
        <img
          src={@project.image}
          class="h-full w-full object-cover object-top"
          alt={@project.name}
        />
      </div>
      <div class="p-8">
        <header class="mb-4">
          <a href={@project.project_url} target="_blank" rel="noopener noreferrer">
            <h2 class="mb-1 text-xl font-black hover:text-purple-900 hover:underline">
              {@project.name}
            </h2>
          </a>
          <a
            :if={@project.repo_url != ""}
            href={@project.repo_url}
            target="_blank"
            rel="noopener noreferrer"
            class="flex flex-row gap-1 align-middle text-sm text-gray-400 hover:text-purple-900 hover:underline"
          >
            <img src="/images/github.svg" width="12" height="12" alt="GitHub" class="opacity-50" />
            View repository
          </a>
        </header>
        <p class="mb-2 text-base text-gray-500">{@project.description}</p>
        <div class="mb-4 inline-block text-xs">
          <.tags tags={@project.tags} />
        </div>
      </div>
    </article>
    """
  end

  defp format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end
end
