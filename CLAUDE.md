# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog and portfolio site for bigardone.dev, built with Phoenix 1.8, LiveView, and Tailwind CSS v4. Uses NimblePublisher for compile-time markdown blog posts.

## Build and Development Commands

```bash
# First-time setup
mix setup                    # Install deps + build assets

# Development
mix phx.server               # Start dev server with watchers
iex -S mix phx.server        # Start with IEx shell

# Testing
mix test                     # Run all tests
mix test test/path/file.exs  # Run specific test file
mix test --failed            # Run only previously failed tests

# Pre-commit (run before committing)
mix precommit                # Compile (warnings as errors) + check deps + format + test

# Blog
mix post                     # Interactive task to create a new blog post
```

## Architecture Overview

### Module Structure

- **BigardoneDev** (`lib/bigardone_dev/`) - Domain/business logic
  - `blog.ex` - Blog context using NimblePublisher (compile-time posts)
  - `blog/post.ex` - Post struct with YAML frontmatter parsing
  - `blog/yaml_parser.ex` - Custom parser for post frontmatter
  - `projects.ex` - Static project data for portfolio section
- **BigardoneDevWeb** (`lib/bigardone_dev_web/`) - Web layer
  - `router.ex` - Routes and pipelines
  - `endpoint.ex` - HTTP endpoint configuration
  - `components/core_components.ex` - Reusable UI components (`<.button>`, `<.input>`, `<.icon>`, `<.flash>`, `<.table>`)
  - `components/blog_components.ex` - Blog-specific components
  - `components/layouts.ex` - App layouts (`root`, `app`)
  - `live/` - LiveView modules

### Routes

| Path | LiveView | Description |
|------|----------|-------------|
| `/` | `HomeLive` | Homepage with recent posts and projects |
| `/blog` | `BlogLive` | Blog listing page |
| `/blog/:year/:month/:day/:slug` | `PostLive` | Individual post view |

### Blog System

Posts are markdown files in `priv/posts/` with YAML frontmatter, compiled at build time via NimblePublisher.

**Post filename format:** `YYYY-MM-DD-slug.md`

**Frontmatter fields:**
- `title` (required) - Post title
- `excerpt` - Short description
- `tags` - Comma-separated or list of tags
- `image` - Optional cover image

**Example:**
```markdown
---
title: My Post Title
excerpt: A short description
tags: elixir, phoenix, liveview
---

Post content in markdown...
```

**Key functions in `BigardoneDev.Blog`:**
- `all_posts/0` - All posts sorted by date descending
- `last_posts/1` - Most recent N posts (default 6)
- `get_post_by_path/1` - Find post by URL path
- `all_tags/0` - All unique tags

### Key Conventions

- Use `BigardoneDevWeb, :controller|:live_view|:html` macros from `bigardone_dev_web.ex`
- Layouts module is pre-aliased; use `<Layouts.app flash={@flash}>` directly
- Verified routes use `~p` sigil (e.g., `~p"/blog"`)
- Posts require recompilation to appear (touch `lib/bigardone_dev/blog.ex` or restart server)

### Asset Pipeline

- **Tailwind v4** - No config file; uses `@import "tailwindcss"` syntax in `assets/css/app.css`
- **Heroicons** - Use `<.icon name="hero-x-mark" />` from CoreComponents
- **No inline scripts** - All JS must go through `assets/js/app.js`


<!-- usage-rules-start -->
<!-- usage-rules-header -->
# Usage Rules

**IMPORTANT**: Consult these usage rules early and often when working with the packages listed below.
Before attempting to use any of these packages or to discover if you should use them, review their
usage rules to understand the correct patterns, conventions, and best practices.
<!-- usage-rules-header-end -->

<!-- phoenix:ecto-start -->
## phoenix:ecto usage
@docs/phoenix_ecto.md
<!-- phoenix:ecto-end -->
<!-- phoenix:elixir-start -->
## phoenix:elixir usage
@docs/phoenix_elixir.md
<!-- phoenix:elixir-end -->
<!-- phoenix:html-start -->
## phoenix:html usage
@docs/phoenix_html.md
<!-- phoenix:html-end -->
<!-- phoenix:liveview-start -->
## phoenix:liveview usage
@docs/phoenix_liveview.md
<!-- phoenix:liveview-end -->
<!-- phoenix:phoenix-start -->
## phoenix:phoenix usage
@docs/phoenix_phoenix.md
<!-- phoenix:phoenix-end -->
<!-- usage_rules-start -->
## usage_rules usage
_A dev tool for Elixir projects to gather LLM usage rules from dependencies_

@docs/usage_rules.md
<!-- usage_rules-end -->
<!-- usage_rules:elixir-start -->
## usage_rules:elixir usage
@docs/usage_rules_elixir.md
<!-- usage_rules:elixir-end -->
<!-- usage_rules:otp-start -->
## usage_rules:otp usage
@docs/usage_rules_otp.md
<!-- usage_rules:otp-end -->
<!-- usage-rules-end -->
