# Static Blog Migration Implementation Plan

## Overview

Migrate the bigardone.dev blog from Next.js to Phoenix 1.8, combining the static content architecture from talento_it_blog (NimblePublisher) with the design and content from the Next.js blog.

## Current State Analysis

### phoenix-bigardone.dev (target)
- Fresh Phoenix 1.8.3 app with LiveView 1.1.0
- Tailwind CSS v4.1.12 (uses `@import "tailwindcss"` syntax)
- No database (no Ecto)
- Single route: `GET /` → `PageController :home`
- CoreComponents already defined (button, input, icon, flash, table)
- Default Phoenix landing page layout

### talento_it_blog (architecture reference)
- NimblePublisher for compile-time static content
- Posts in `/posts/*.md` with Elixir map frontmatter
- Post struct with: body, date, excerpt, id, path, reading_time, tags, title
- 200 words/min reading time calculation
- Categories support (we won't use this)

### bigardone.dev (design/content source)
- 100+ posts in `/blog/` with YAML frontmatter
- URL pattern: `/blog/YYYY/MM/DD/slug`
- Design: Purple/gray theme, Montserrat font, custom shadows
- Components: Header (logo + nav), Footer (copyright + social), PostCard, Tags
- Sections: Hero, Latest articles, Projects

## Desired End State

A fully functional Phoenix blog with:
- Homepage with hero section, latest 6 articles, and projects section
- Blog listing page with all articles
- Individual post pages with rendered markdown and syntax highlighting
- Design matching bigardone.dev (purple theme, Montserrat font, wave dividers)
- Hot reload on markdown file changes in development

### Verification:
1. `mix phx.server` starts without errors
2. Homepage displays hero, latest articles, and projects
3. `/blog` shows all articles in a grid
4. `/blog/2022/01/31/some-post` renders markdown with syntax highlighting
5. All styles match bigardone.dev design

## What We're NOT Doing

- Tag filtering on blog listing (future enhancement)
- Related posts section on post detail (future enhancement)
- RSS feed (future enhancement)
- Search functionality
- Comments integration
- Categories (only tags)
- SEO meta tags (future enhancement)

## Implementation Approach

We'll implement in 6 phases, each building on the previous:
1. Dependencies & fonts
2. Content infrastructure (NimblePublisher + Post module)
3. Layout components (header, footer, wave dividers)
4. Blog components (post card, post meta, tags)
5. LiveViews (home, blog listing, post detail)
6. Content migration (copy posts and images)

---

## Phase 1: Dependencies & Fonts

### Overview
Add NimblePublisher, YAML parser, and markdown processing dependencies. Configure Montserrat font.

### Changes Required:

#### 1. Add dependencies
**File**: `mix.exs`
**Changes**: Add NimblePublisher and related deps to the `deps/0` function

```elixir
# Add these dependencies:
{:nimble_publisher, "~> 1.1"},
{:yaml_elixir, "~> 2.9"},
{:earmark, "~> 1.4"},
{:makeup, "~> 1.2"},
{:makeup_elixir, "~> 1.0"},
{:makeup_js, "~> 0.1"}
```

#### 2. Configure Montserrat font
**File**: `lib/bigardone_dev_web/components/layouts/root.html.heex`
**Changes**: Add Google Fonts link for Montserrat

```heex
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;700;900&display=swap" rel="stylesheet" />
```

#### 3. Configure Tailwind custom theme
**File**: `assets/css/app.css`
**Changes**: Add custom colors, shadows, and font family using Tailwind v4 syntax

```css
@theme {
  --color-purple-1000: #1c1648;
  --font-sans: 'Montserrat', sans-serif;
  --shadow-custom: 0px 8px 16px 0px rgb(0 0 0 / 3%);
  --shadow-custom-hover: 0px 8px 16px 0px rgb(0 0 0 / 6%);
}
```

### Success Criteria:

#### Automated Verification:
- [x] Dependencies install: `mix deps.get`
- [x] Project compiles: `mix compile`
- [x] Server starts: `mix phx.server`

#### Visual Verification (Playwright MCP):
- [x] Navigate to `http://localhost:4000` using `browser_navigate`
- [x] Take snapshot with `browser_snapshot` to verify page loads
- [x] Use `browser_evaluate` to check font-family: `() => getComputedStyle(document.body).fontFamily` should include "Montserrat"

---

## Phase 2: Content Infrastructure

### Overview
Create the Post module with NimblePublisher, blog directory structure, and Blog context API.

### Changes Required:

#### 1. Create posts directory
**Directory**: `priv/posts/`
**Changes**: Create empty directory for markdown files

```bash
mkdir -p priv/posts
```

#### 2. Create Post struct module
**File**: `lib/bigardone_dev/blog/post.ex`
**Changes**: Define Post struct with YAML frontmatter parsing

```elixir
defmodule BigardoneDev.Blog.Post do
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
      [
        id: slug,
        title: attrs.title,
        date: date,
        excerpt: attrs[:excerpt] || "",
        body: body,
        path: path,
        reading_time: reading_time,
        tags: tags,
        image: attrs[:image]
      ]
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
```

#### 3. Create Blog context with NimblePublisher
**File**: `lib/bigardone_dev/blog.ex`
**Changes**: Configure NimblePublisher and define content API

```elixir
defmodule BigardoneDev.Blog do
  alias BigardoneDev.Blog.Post

  use NimblePublisher,
    build: Post,
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
```

#### 4. Create YAML parser module
**File**: `lib/bigardone_dev/blog/yaml_parser.ex`
**Changes**: Custom parser to handle YAML frontmatter

```elixir
defmodule BigardoneDev.Blog.YamlParser do
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
```

#### 5. Configure hot reload for markdown
**File**: `config/dev.exs`
**Changes**: Add pattern for markdown files in live_reload

```elixir
# Add to the patterns list:
~r"priv/posts/.*\.(md)$"
```

#### 6. Add a test post
**File**: `priv/posts/2024-01-01-test-post.md`
**Changes**: Create a test post to verify the setup

```markdown
---
title: "Test Post"
date: "2024-01-01"
excerpt: "This is a test post to verify NimblePublisher setup"
tags: elixir, phoenix
---

# Hello World

This is a test post with **bold** and *italic* text.

## Code Example

```elixir
defmodule Hello do
  def world, do: "Hello, World!"
end
```
```

### Success Criteria:

#### Automated Verification:
- [x] Project compiles: `mix compile`
- [x] Verify posts via IEx: `iex -S mix -e "IO.inspect(BigardoneDev.Blog.all_posts(), label: \"Posts\")"`
- [x] Posts are parsed correctly: posts list contains test post with correct fields

---

## Phase 3: Layout Components

### Overview
Replace default Phoenix layout with bigardone.dev design: header with logo + navigation, footer with copyright + social links, wave divider SVGs.

### Changes Required:

#### 1. Copy static assets
**Directory**: `priv/static/images/`
**Changes**: Copy SVG assets from Next.js blog

Copy from `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/public/images/`:
- `logo.svg` - Site logo
- `bigardone.svg` - Avatar illustration
- `github.svg` - GitHub icon
- `twitter.svg` - Twitter icon
- `linkedin.svg` - LinkedIn icon

#### 2. Update root layout
**File**: `lib/bigardone_dev_web/components/layouts/root.html.heex`
**Changes**: Add fonts, update title, add smooth scroll

```heex
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="csrf-token" content={get_csrf_token()} />
    <.live_title default="bigardone.dev">
      {assigns[:page_title]}
    </.live_title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;700;900&display=swap" rel="stylesheet" />
    <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
    <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}>
    </script>
  </head>
  <body class="font-sans antialiased">
    {@inner_content}
  </body>
</html>
```

#### 3. Create layout components
**File**: `lib/bigardone_dev_web/components/layouts.ex`
**Changes**: Replace app layout with header, main, wave divider, footer

```elixir
defmodule BigardoneDevWeb.Layouts do
  use BigardoneDevWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_path, :string, default: "/"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col">
      <.header current_path={@current_path} />
      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>
      <.wave_divider color="gray-50" />
      <.footer />
    </div>
    <.flash_group flash={@flash} />
    """
  end

  attr :current_path, :string, default: "/"

  def header(assigns) do
    ~H"""
    <header class="w-full max-w-6xl px-4 mx-auto">
      <div class="flex flex-row items-center justify-between py-6">
        <div class="flex-1">
          <a href="/">
            <img src={~p"/images/logo.svg"} width="70" height="50" alt="bigardone.dev" />
          </a>
        </div>
        <nav class="flex flex-row flex-1">
          <ul class="flex flex-row justify-end w-full text-sm gap-x-4">
            <li class="ml-6">
              <.nav_link href="/" current_path={@current_path}>Home</.nav_link>
            </li>
            <li class="ml-6">
              <.nav_link href="/blog" current_path={@current_path}>Articles</.nav_link>
            </li>
          </ul>
        </nav>
      </div>
    </header>
    """
  end

  attr :href, :string, required: true
  attr :current_path, :string, required: true
  slot :inner_block, required: true

  defp nav_link(assigns) do
    active? = assigns.current_path == assigns.href or
              (assigns.href == "/blog" and String.starts_with?(assigns.current_path, "/blog"))

    assigns = assign(assigns, :active?, active?)

    ~H"""
    <a
      href={@href}
      class={[
        "block font-black text-black hover:text-purple-600 transition-colors",
        @active? && "text-purple-900"
      ]}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer class="pt-2 pb-6 text-gray-600 md:pb-12 md:pt-0 bg-gray-50">
      <div class="flex flex-row justify-between w-full max-w-6xl px-4 mx-auto text-sm align-middle">
        <div class="w-3/5 md:w-9/12">
          bigardone.dev &copy; {DateTime.utc_now().year}
        </div>
        <div class="flex flex-row justify-end w-2/5 gap-x-10 md:w-2/12">
          <a class="flex-1 block text-right" href="https://github.com/bigardone" target="_blank">
            <img src={~p"/images/github.svg"} width="24" height="24" alt="GitHub" />
          </a>
          <a class="flex-1 block text-right" href="https://twitter.com/bigardone" target="_blank">
            <img src={~p"/images/twitter.svg"} width="24" height="24" alt="Twitter" />
          </a>
          <a class="flex-1 block text-right" href="https://www.linkedin.com/in/ricardogarciavega/" target="_blank">
            <img src={~p"/images/linkedin.svg"} width="24" height="24" alt="LinkedIn" />
          </a>
        </div>
      </div>
    </footer>
    """
  end

  attr :color, :string, default: "gray-50"
  attr :flip, :boolean, default: false

  def wave_divider(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 1440 320"
      class={@flip && "rotate-180"}
    >
      <path
        fill={wave_color(@color)}
        fill-opacity="1"
        d="M0,192L48,197.3C96,203,192,213,288,229.3C384,245,480,267,576,250.7C672,235,768,181,864,181.3C960,181,1056,235,1152,234.7C1248,235,1344,181,1392,154.7L1440,128L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"
      />
    </svg>
    """
  end

  defp wave_color("gray-50"), do: "#F9FAFB"
  defp wave_color("purple-50"), do: "#F5F3FF"
  defp wave_color(_), do: "#F9FAFB"

  # Keep existing flash_group function
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end
end
```

### Success Criteria:

#### Automated Verification:
- [x] Project compiles: `mix compile`
- [x] Server starts: `mix phx.server`

#### Visual Verification (Playwright MCP):
- [x] Navigate to `http://localhost:4000` using `browser_navigate`
- [x] Take snapshot with `browser_snapshot` to capture full layout
- [x] Verify header logo exists: `browser_evaluate` with `() => document.querySelector('header img[alt="bigardone.dev"]') !== null`
- [x] Verify navigation links: `browser_snapshot` should show "Home" and "Articles" links
- [x] Verify footer with social links: `browser_evaluate` with `() => document.querySelectorAll('footer a[target="_blank"]').length === 3`
- [x] Navigate to `/blog` and take `browser_snapshot` to verify "Articles" nav link is highlighted
- [x] Verify SVG icons load: `browser_evaluate` with `() => document.querySelectorAll('img[src*=".svg"]').length > 0`

---

## Phase 4: Blog Components

### Overview
Create reusable components for blog content: post cards, post meta (date + reading time), tags, section headings, and project cards.

### Changes Required:

#### 1. Create blog components module
**File**: `lib/bigardone_dev_web/components/blog_components.ex`
**Changes**: Define all blog-specific UI components

```elixir
defmodule BigardoneDevWeb.BlogComponents do
  use Phoenix.Component

  attr :text, :string, required: true

  def section_heading(assigns) do
    ~H"""
    <div class="mb-16 text-3xl font-black text-purple-1000">
      <span class="inline-block py-6">
        {@text}
      </span>
    </div>
    """
  end

  attr :post, :map, required: true

  def post_card(assigns) do
    ~H"""
    <article class="p-8 bg-white rounded-lg cursor-pointer shadow-custom hover:shadow-custom-hover duration-300 transition-shadow">
      <.link navigate={@post.path}>
        <header class="mb-5">
          <h2 class="mb-6 text-xl font-black hover:underline hover:text-purple-900">
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
      {format_date(@date)} &middot; {@reading_time} min read
      <.tags tags={@tags} />
    </div>
    """
  end

  defp format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end

  attr :tags, :list, default: []

  def tags(assigns) do
    ~H"""
    <div class="flex flex-wrap mt-2 text-xs">
      <div :for={tag <- @tags} class="p-2 mb-2 mr-2 bg-gray-100 rounded-md">
        {tag}
      </div>
    </div>
    """
  end

  attr :project, :map, required: true

  def project_card(assigns) do
    ~H"""
    <article class="relative border border-gray-100 rounded-lg bg-white shadow-custom hover:shadow-custom-hover duration-300 transition-shadow">
      <div class="relative overflow-hidden bg-purple-400 rounded-t-lg h-44">
        <img
          src={@project.image}
          class="w-full h-full object-cover object-top"
          alt={@project.name}
        />
      </div>
      <div class="p-8">
        <header class="mb-4">
          <a href={@project.project_url} target="_blank" rel="noopener noreferrer">
            <h2 class="mb-1 text-xl font-black hover:underline hover:text-purple-900">
              {@project.name}
            </h2>
          </a>
          <a
            :if={@project.repo_url != ""}
            href={@project.repo_url}
            target="_blank"
            rel="noopener noreferrer"
            class="flex flex-row text-sm text-gray-400 align-middle gap-1 hover:underline hover:text-purple-900"
          >
            <img src={~p"/images/github.svg"} width="12" height="12" alt="GitHub" class="opacity-50" />
            View repository
          </a>
        </header>
        <p class="mb-2 text-base text-gray-500">{@project.description}</p>
        <div class="inline-block mb-4 text-xs">
          <.tags tags={@project.tags} />
        </div>
      </div>
    </article>
    """
  end
end
```

#### 2. Import blog components in web module
**File**: `lib/bigardone_dev_web.ex`
**Changes**: Add BlogComponents to the html_helpers

```elixir
# In the html_helpers function, add:
import BigardoneDevWeb.BlogComponents
```

### Success Criteria:

#### Automated Verification:
- [x] Project compiles: `mix compile`

#### Visual Verification (Playwright MCP):
- [x] Components will be verified in Phase 5 via browser testing

---

## Phase 5: LiveViews

### Overview
Create the three main LiveViews: HomeLive (landing page), BlogLive (articles listing), PostLive (individual post).

### Changes Required:

#### 1. Create Projects module
**File**: `lib/bigardone_dev/projects.ex`
**Changes**: Static project data

```elixir
defmodule BigardoneDev.Projects do
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
```

#### 2. Create HomeLive
**File**: `lib/bigardone_dev_web/live/home_live.ex`
**Changes**: Homepage with hero, latest articles, and projects

```elixir
defmodule BigardoneDevWeb.HomeLive do
  use BigardoneDevWeb, :live_view

  alias BigardoneDev.Blog
  alias BigardoneDev.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Home")
     |> assign(:current_path, "/")
     |> assign(:latest_posts, Blog.last_posts(6))
     |> assign(:projects, Projects.all())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="md:mt-32 mt-16">
      <%!-- Hero Section --%>
      <section class="md:grid md:grid-flow-row md:grid-cols-2 md:gap-4 w-full max-w-6xl px-4 mx-auto">
        <div class="md:mb-0 mb-6 text-xl leading-relaxed text-gray-700">
          <p class="font-black">
            Hi, how are you doing? I'm Ricardo.
          </p>
          <h1 class="text-purple-1000 my-8 text-4xl font-black">
            I'm a software engineer.
          </h1>
          <p class="mb-6">
            I love building web applications using modern technologies such as
            <strong>Elixir</strong>, <strong>Phoenix</strong>, and <strong>LiveView</strong>
            and sharing my coding experience in this blog.
          </p>
          <p>
            Feel free to read any of my
            <a href="#latest_articles" class="hover:underline font-black text-purple-700">latest articles</a>
            or take a look at my
            <a href="#recent_projects" class="hover:underline font-black text-purple-700">recent projects</a>.
            I hope you enjoy them.
          </p>
        </div>
        <div class="md:justify-end flex flex-row justify-center w-auto">
          <div class="md:w-auto w-3/4">
            <img src={~p"/images/bigardone.svg"} width="400" height="400" alt="Ricardo" />
          </div>
        </div>
      </section>

      <%!-- Wave to purple section --%>
      <Layouts.wave_divider color="purple-50" />

      <%!-- Latest Articles Section --%>
      <section class="bg-purple-50" id="latest_articles">
        <div class="max-w-6xl px-4 mx-auto">
          <.section_heading text="Latest articles" />
          <div class="grid grid-flow-row md:grid-cols-2 grid-cols-1 gap-8">
            <.post_card :for={post <- @latest_posts} post={post} />
            <div>
              <a
                href="/blog"
                class="shadow-custom hover:underline hover:shadow-custom-hover block p-8 font-black text-center text-purple-900 bg-purple-200 rounded-lg"
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
      <section class="max-w-6xl px-4 mx-auto" id="recent_projects">
        <.section_heading text="Recent projects" />
        <div class="grid grid-flow-row md:grid-cols-3 grid-cols-1 gap-8">
          <.project_card :for={project <- @projects} project={project} />
        </div>
      </section>
    </div>
    """
  end
end
```

#### 3. Create BlogLive
**File**: `lib/bigardone_dev_web/live/blog_live.ex`
**Changes**: Blog listing page with all articles

```elixir
defmodule BigardoneDevWeb.BlogLive do
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
    <section class="max-w-6xl px-4 py-12 mx-auto md:py-32">
      <.section_heading text="Articles" />
      <div class="grid grid-flow-row grid-cols-1 md:grid-cols-2 gap-8">
        <.post_card :for={post <- @posts} post={post} />
      </div>
    </section>
    """
  end
end
```

#### 4. Create PostLive
**File**: `lib/bigardone_dev_web/live/post_live.ex`
**Changes**: Individual post page with rendered markdown

```elixir
defmodule BigardoneDevWeb.PostLive do
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
    <section class="px-4 mx-auto mt-16 md:mt-32 prose md:prose-lg prose-purple max-w-none md:max-w-4xl">
      <header class="mb-10">
        <h1 class="mb-4 font-black">{@post.title}</h1>
        <div class="mb-4 text-xl text-gray-500">{@post.excerpt}</div>
        <.post_meta date={@post.date} reading_time={@post.reading_time} tags={@post.tags} />
      </header>
      <article class="mb-16">
        {raw(@post.body)}
      </article>
    </section>
    """
  end
end
```

#### 5. Update router
**File**: `lib/bigardone_dev_web/router.ex`
**Changes**: Replace PageController with LiveViews

```elixir
defmodule BigardoneDevWeb.Router do
  use BigardoneDevWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BigardoneDevWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", BigardoneDevWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/blog", BlogLive
    live "/blog/:year/:month/:day/:slug", PostLive
  end
end
```

#### 6. Add Tailwind typography plugin
**File**: `assets/css/app.css`
**Changes**: Add prose styles for markdown content

```css
/* Add to existing @theme block */
@plugin "@tailwindcss/typography";

/* Custom prose styles for purple theme */
.prose-purple a {
  @apply text-purple-700 hover:text-purple-900;
}

.prose-purple code {
  @apply bg-gray-100 px-1 py-0.5 rounded;
}

.prose-purple pre {
  @apply bg-gray-900;
}
```

#### 7. Install typography plugin
**File**: `package.json` (or via npm)
**Changes**: Add Tailwind typography plugin

```bash
cd assets && npm install @tailwindcss/typography
```

### Success Criteria:

#### Automated Verification:
- [ ] Project compiles: `mix compile`
- [ ] Server starts: `mix phx.server`

#### Visual Verification (Playwright MCP):

**Homepage (`/`):**
- [ ] Navigate to `http://localhost:4000` using `browser_navigate`
- [ ] Take `browser_snapshot` to capture homepage
- [ ] Verify hero section: `browser_evaluate` with `() => document.querySelector('h1').textContent.includes("software engineer")`
- [ ] Verify avatar image: `browser_evaluate` with `() => document.querySelector('img[alt="Ricardo"]') !== null`
- [ ] Verify "Latest articles" section heading exists in snapshot
- [ ] Verify post cards: `browser_evaluate` with `() => document.querySelectorAll('article').length >= 6`
- [ ] Verify "View more articles" link: `browser_evaluate` with `() => document.querySelector('a[href="/blog"]') !== null`
- [ ] Verify "Recent projects" section and project cards in snapshot
- [ ] Verify wave dividers: `browser_evaluate` with `() => document.querySelectorAll('svg path').length >= 2`

**Blog listing (`/blog`):**
- [ ] Navigate to `http://localhost:4000/blog` using `browser_navigate`
- [ ] Take `browser_snapshot` to capture blog page
- [ ] Verify "Articles" heading exists in snapshot
- [ ] Verify post cards grid: `browser_evaluate` with `() => document.querySelectorAll('article').length > 0`

**Post detail (click from listing):**
- [ ] Use `browser_click` on first article link to navigate to a post
- [ ] Take `browser_snapshot` to capture post page
- [ ] Verify post title in `<h1>`: `browser_evaluate` with `() => document.querySelector('h1') !== null`
- [ ] Verify post metadata (date, reading time): snapshot should show date and "min read"
- [ ] Verify tags display: `browser_evaluate` with `() => document.querySelectorAll('.bg-gray-100').length > 0`
- [ ] Verify article body renders: `browser_evaluate` with `() => document.querySelector('article').innerHTML.length > 100`

**Navigation state:**
- [ ] Navigate to `/` and take snapshot - "Home" should appear active (text-purple-900 class)
- [ ] Navigate to `/blog` and take snapshot - "Articles" should appear active

---

## Phase 6: Content Migration

### Overview
Copy all markdown posts and images from the Next.js blog to the Phoenix project.

### Changes Required:

#### 1. Copy markdown posts
**Source**: `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/blog/`
**Destination**: `/Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev/priv/posts/`

```bash
cp /Users/ricardogarciavega/projects/bigardone/bigardone.dev/blog/*.md \
   /Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev/priv/posts/
```

#### 2. Copy images
**Source**: `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/public/images/`
**Destination**: `/Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev/priv/static/images/`

```bash
cp -r /Users/ricardogarciavega/projects/bigardone/bigardone.dev/public/images/* \
      /Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev/priv/static/images/
```

#### 3. Remove test post
**File**: `priv/posts/2024-01-01-test-post.md`
**Changes**: Delete the test post created in Phase 2

```bash
rm priv/posts/2024-01-01-test-post.md
```

### Success Criteria:

#### Automated Verification:
- [ ] Project compiles with all posts: `mix compile`
- [ ] No parsing errors in compilation output
- [ ] Verify post count via IEx: `iex -S mix -e "IO.puts(length(BigardoneDev.Blog.all_posts()))"`

#### Visual Verification (Playwright MCP):

**Homepage with real content:**
- [ ] Navigate to `http://localhost:4000` using `browser_navigate`
- [ ] Take `browser_snapshot` to capture homepage with real articles
- [ ] Verify 6 real post cards: `browser_evaluate` with `() => document.querySelectorAll('article').length >= 6`
- [ ] Verify posts have real titles (not "Test Post"): `browser_evaluate` with `() => !document.body.textContent.includes("Test Post")`

**Blog listing with all posts:**
- [ ] Navigate to `http://localhost:4000/blog` using `browser_navigate`
- [ ] Take `browser_snapshot` to capture full blog listing
- [ ] Verify many post cards: `browser_evaluate` with `() => document.querySelectorAll('article').length > 50`

**Post with images and code:**
- [ ] Navigate to a known post URL (e.g., a recent Elixir tutorial)
- [ ] Take `browser_snapshot` to capture post
- [ ] Verify images render: `browser_evaluate` with `() => document.querySelectorAll('article img').length > 0` (for posts with images)
- [ ] Verify syntax highlighting: `browser_evaluate` with `() => document.querySelectorAll('pre code').length > 0`
- [ ] Take `browser_take_screenshot` to save visual proof of syntax highlighting

**URL pattern verification:**
- [ ] Click on several posts from the blog listing and verify URLs match `/blog/YYYY/MM/DD/slug` pattern via `browser_snapshot` showing the URL or via network requests

---

## Testing Strategy

### Playwright MCP Testing Workflow:

Each phase verification follows this pattern:
1. Ensure server is running: `mix phx.server` (in background)
2. Use `browser_navigate` to navigate to the target URL
3. Use `browser_snapshot` to capture accessible page structure
4. Use `browser_evaluate` to run JavaScript assertions
5. Use `browser_take_screenshot` when visual proof is needed
6. Use `browser_click` to interact with elements (e.g., navigation, post links)

### Full Integration Test (Playwright MCP):

```
1. browser_navigate to http://localhost:4000
2. browser_snapshot - verify hero section, articles, projects
3. browser_click on "View more articles" link
4. browser_snapshot - verify we're on /blog with all articles
5. browser_click on first article
6. browser_snapshot - verify post renders with title, meta, body
7. browser_click on "Home" in navigation
8. browser_snapshot - verify we're back on homepage
9. browser_click on "Articles" in navigation
10. browser_snapshot - verify Articles nav is highlighted
```

### Edge Cases to Test (with Playwright MCP):

**Post with no tags:**
- Navigate to a post without tags
- `browser_evaluate`: `() => document.querySelectorAll('.bg-gray-100').length === 0`

**Post with many tags:**
- Navigate to a post with many tags
- `browser_snapshot` to verify tags wrap correctly

**Post with code blocks in multiple languages:**
- Navigate to a post with Elixir, JavaScript, and HTML code
- `browser_evaluate`: `() => document.querySelectorAll('pre code').length >= 3`

**Post with images:**
- Navigate to a post with embedded images
- `browser_evaluate`: `() => Array.from(document.querySelectorAll('article img')).every(img => img.complete && img.naturalHeight > 0)`

**Very long post title:**
- Navigate to a post with a long title
- `browser_snapshot` to verify title doesn't break layout

**Special characters in post content:**
- Navigate to a post with code examples containing `{`, `}`, `<`, `>`
- `browser_snapshot` to verify content renders correctly (not interpreted as HTML)

---

## Performance Considerations

- All posts are compiled into the application binary at compile time
- No database queries needed for content
- Images served from static assets with proper caching headers
- Consider lazy loading images for posts listing page

---

## References

- Original research: `thoughts/shared/research/2025-12-19_11-24-29_static-blog-migration.md`
- talento_it_blog architecture: `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog`
- bigardone.dev design: `/Users/ricardogarciavega/projects/bigardone/bigardone.dev`
- NimblePublisher docs: https://hexdocs.pm/nimble_publisher
