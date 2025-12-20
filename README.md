# bigardone.dev

My personal website and blog built with Phoenix 1.8, LiveView, and Tailwind CSS v4.

## Features

- **Blog** - Articles about Elixir, Phoenix, LiveView, and web development
- **Projects** - Showcase of recent open source projects
- **Markdown-based content** - Blog posts powered by NimblePublisher with syntax highlighting

## Tech Stack

- [Elixir](https://elixir-lang.org/) & [Phoenix](https://www.phoenixframework.org/) 1.8
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
- [Tailwind CSS](https://tailwindcss.com/) v4
- [NimblePublisher](https://hexdocs.pm/nimble_publisher) for static blog content
- [Makeup](https://hexdocs.pm/makeup) for code syntax highlighting

## Development

```bash
# First-time setup
mix setup

# Start the development server
mix phx.server

# Or start with IEx shell
iex -S mix phx.server
```

Visit [localhost:4000](http://localhost:4000) in your browser.

## Testing

```bash
# Run all tests
mix test

# Run pre-commit checks (compile, format, test)
mix precommit
```

## License

MIT
