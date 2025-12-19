---
date: 2025-12-19T11:24:29Z
researcher: Claude
git_commit: 7f3bf6f0760fb78e6b240fd2dd68ae4ac78d0ed2
branch: main
repository: phoenix-bigardone.dev
topic: "Static Blog Migration: Combining talento_it_blog Architecture with bigardone.dev Design"
tags: [research, codebase, phoenix, liveview, nimble-publisher, static-content, blog, migration]
status: complete
last_updated: 2025-12-19
last_updated_by: Claude
last_updated_note: "Added live URL reference for bigardone.dev"
---

# Research: Static Blog Migration

**Date**: 2025-12-19T11:24:29Z
**Researcher**: Claude
**Git Commit**: 7f3bf6f0760fb78e6b240fd2dd68ae4ac78d0ed2
**Branch**: main
**Repository**: phoenix-bigardone.dev

## Research Question

Create a research document to make phoenix-bigardone.dev behave like talento_it_blog (static content architecture), but with the layout, style, and contents from the Next.js bigardone.dev blog.

## Summary

This research analyzes three codebases to plan the migration of a personal blog to Phoenix:

1. **phoenix-bigardone.dev** (current): Fresh Phoenix 1.8 app with Tailwind v4, no content features yet
2. **talento_it_blog**: Phoenix blog using NimblePublisher for compile-time static content from markdown files
3. **bigardone.dev**: Next.js blog with 100+ posts, purple/gray design, Montserrat typography

The goal is to combine the static content architecture from talento_it_blog with the design and content from the Next.js blog.

---

## Detailed Findings

### 1. Current Phoenix Project (phoenix-bigardone.dev)

**Location**: `/Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev`

**Stack**:
- Phoenix 1.8.3 with LiveView 1.1.0
- Tailwind CSS v4.1.12 (no config file, uses `@import "tailwindcss"`)
- Heroicons v2.2.0
- No database (no Ecto)
- Bandit server

**Current State**:
- Single route: `GET /` → `PageController :home`
- Default Phoenix landing page
- CoreComponents already defined (button, input, icon, flash, table, etc.)
- Layouts module with app layout structure
- LiveView infrastructure ready but unused

**Key Files**:
- `lib/bigardone_dev_web/router.ex` - Single home route
- `lib/bigardone_dev_web/components/core_components.ex` - 430+ lines of UI components
- `lib/bigardone_dev_web/components/layouts.ex` - App layout structure
- `assets/css/app.css` - Tailwind v4 setup

---

### 2. talento_it_blog - Static Content Architecture

**Location**: `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog`

**Content Architecture**:

#### Storage
- Markdown files in `/posts/` directory (222 posts)
- Naming convention: `YYYY-MM-DD-kebab-case-slug.md`

#### NimblePublisher Configuration
```elixir
# lib/talento_it_blog.ex
use NimblePublisher,
  build: TalentoItBlog.Post,
  from: "./posts/*.md",
  as: :posts
```

#### Frontmatter Format (Elixir map style)
```elixir
%{
  title: "Post Title",
  excerpt: "Brief description",
  image: "/images/header.png",
  date: "2020-10-27",
  categories: ["category1", "category2"],
  tags: ["tag1", "tag2"]
}
---
# Markdown content here
```

#### Post Struct
```elixir
# lib/talento_it_blog/post.ex
defstruct [
  :body,           # Parsed HTML from markdown
  :categories,     # List of Category structs
  :date,           # Date struct
  :excerpt,        # Short description
  :id,             # Slug from filename
  :image,          # Featured image path
  :path,           # URL path
  :reading_time,   # Calculated from word count
  :tags,           # List of tag strings
  :title,          # Post title
  author: "Default Author",
  author_email: "default@email.com"
]

def build(filename, attrs, body) do
  [year, month, day, id] = parse_filename(filename)
  date = Date.from_iso8601!("#{year}-#{month}-#{day}")
  reading_time = calculate_reading_time(body)
  # ... build struct
end
```

#### Content API
```elixir
# lib/talento_it_blog.ex
@posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

def all_posts, do: @posts
def last_posts(count \\ 5), do: Enum.take(@posts, count)
def get_post_by_id(id), do: Enum.find(@posts, &(&1.id == id))
def list_posts_by_category(category), do: # filter by category
def get_related_posts(post), do: # 3 random posts from same categories
def all_categories, do: @categories
def all_tags, do: @tags
```

#### Router Configuration
```elixir
# lib/talento_it_blog_web/router.ex
live("/", HomeLive)          # All posts list
live("/acerca", AboutLive)   # About page
live("/:id", PostLive)       # Individual post by ID
```

#### Hot Reload Configuration
```elixir
# config/dev.exs
live_reload: [
  patterns: [
    ~r"posts/.*(md)$",  # Watch markdown files
    # ... other patterns
  ]
]
```

**Key Files to Reference**:
- `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog/lib/talento_it_blog.ex`
- `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog/lib/talento_it_blog/post.ex`
- `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog/lib/talento_it_blog/category.ex`
- `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog/lib/talento_it_blog_web/live/post_live.ex`
- `/Users/ricardogarciavega/projects/bigardone/talento_it/talento_it_blog/lib/talento_it_blog_web/live/home_live.ex`

---

### 3. bigardone.dev - Next.js Blog Design & Content

**Location**: `/Users/ricardogarciavega/projects/bigardone/bigardone.dev`
**Live URL**: https://bigardone.dev

**Content Structure**:
- 100+ posts in `/blog/` directory
- Naming: `YYYY-MM-DD-slug.md`
- URL pattern: `/blog/2022/01/31/post-slug`

#### Frontmatter Schema (YAML)
```yaml
---
title: "Post Title"
date: "2022-01-31"
excerpt: "Brief summary of the post"
tags: elixir, phoenix, liveview
image: "https://bigardone.dev/images/blog/2022-01-31.../post-meta.png"
---
```

#### Reading Time Calculation
```javascript
Math.ceil(wordCount / 250)  // ~250 words per minute
```

#### Design System

**Color Palette**:
- Primary: Purple (`purple-900`, `purple-700`, custom `purple-1000: #1c1648`)
- Backgrounds: White, light purple (`purple-50: #F5F3FF`), gray (`gray-50`, `gray-100`)
- Text: Dark gray (`gray-500`), black, dark purple

**Typography**:
- Headings: Montserrat, black weight (font-weight: 900)
- Body: Montserrat, regular weight
- Code: Fira Code

**Layout Structure**:
```
┌─────────────────────────────────────────┐
│ Header (Logo + Navigation)              │
├─────────────────────────────────────────┤
│ Main Content                            │
├─────────────────────────────────────────┤
│ SVG Wave Divider                        │
├─────────────────────────────────────────┤
│ Footer (Copyright + Social Links)       │
└─────────────────────────────────────────┘
```

**Header**:
- Logo: `/images/logo.svg` (70x50px)
- Navigation: "Home" and "Articles"
- Active link highlighting

**Footer**:
- Copyright: "bigardone.dev © {year}"
- Social links: GitHub, Twitter, LinkedIn (SVG icons)
- Light gray background

**Homepage Sections**:
1. Hero with intro text and avatar image
2. "Latest articles" (6 most recent posts)
3. "Recent projects" section
4. SVG wave dividers between sections

**Component Styles**:
- Cards: White bg, `rounded-lg`, custom shadow, hover effects
- Post meta: date · reading time + tags
- Tags: Small gray badges with light background

**Key Files to Reference**:
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/components/layout.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/components/header.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/components/footer.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/components/postCard.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/pages/index.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/pages/blog.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/tailwind.config.js`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/css/index.css`
- `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/data/projects.js`

---

## Implementation Plan

### Phase 1: Dependencies & Project Setup

1. **Add NimblePublisher and related dependencies**
   ```elixir
   # mix.exs
   {:nimble_publisher, "~> 1.1"},
   {:earmark, "~> 1.4"},
   {:makeup, "~> 1.1"},
   {:makeup_elixir, "~> 0.16"},
   {:makeup_js, "~> 0.1"},      # For JS code highlighting
   {:phoenix_seo, "~> 0.1"}     # Optional: SEO metadata
   ```

2. **Add Montserrat and Fira Code fonts**
   - Install via npm in assets or use Google Fonts CDN
   - Update `assets/css/app.css` with font imports

3. **Configure Tailwind v4 custom colors**
   - Add `purple-1000: #1c1648` custom color
   - Add custom shadow utilities

### Phase 2: Content Infrastructure

1. **Create posts directory structure**
   ```
   /priv/posts/
     YYYY-MM-DD-slug.md
     ...
   ```

2. **Copy and adapt Post module from talento_it_blog**
   - `lib/bigardone_dev/blog/post.ex` - Post struct and builder
   - Adapt frontmatter to match Next.js YAML format
   - Keep reading time calculation (use 250 words/min like Next.js)

3. **Create main Blog context**
   - `lib/bigardone_dev/blog.ex` - NimblePublisher loader and API
   - Functions: `all_posts/0`, `get_post/1`, `last_posts/1`, `all_tags/0`

4. **Configure hot reload for markdown**
   - Update `config/dev.exs` with pattern for `priv/posts/*.md`

### Phase 3: Layout & Components

1. **Update root layout** (`lib/bigardone_dev_web/components/layouts/root.html.heex`)
   - Add Montserrat/Fira Code font imports
   - Set base typography classes

2. **Create layout components** (`lib/bigardone_dev_web/components/layouts.ex`)
   - `.header/1` - Logo + navigation (Home, Articles)
   - `.footer/1` - Copyright + social links
   - `.wave_divider/1` - SVG wave separator
   - Update `.app/1` to use new header/footer

3. **Create blog components** (`lib/bigardone_dev_web/components/blog_components.ex`)
   - `.post_card/1` - Card for post listing
   - `.post_meta/1` - Date, reading time, tags
   - `.tags/1` - Tag badges
   - `.heading/1` - Section headings
   - `.project_card/1` - For projects section

4. **Add SVG assets**
   - Copy logo, avatar, social icons, wave dividers from Next.js blog
   - Place in `priv/static/images/`

### Phase 4: LiveViews

1. **HomeLive** (`lib/bigardone_dev_web/live/home_live.ex`)
   - Hero section with avatar and intro text
   - Latest articles grid (6 posts)
   - Projects section
   - Wave dividers between sections

2. **BlogLive** (`lib/bigardone_dev_web/live/blog_live.ex`)
   - All articles grid
   - Optional tag filtering

3. **PostLive** (`lib/bigardone_dev_web/live/post_live.ex`)
   - Post header with title, meta, share buttons
   - Rendered markdown content (use `raw/1`)
   - Related posts section (optional)

4. **Update Router**
   ```elixir
   live "/", HomeLive
   live "/blog", BlogLive
   live "/blog/:year/:month/:day/:slug", PostLive
   ```

### Phase 5: Content Migration

1. **Copy markdown files from Next.js blog**
   - From: `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/blog/`
   - To: `/Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev/priv/posts/`

2. **Convert frontmatter format if needed**
   - Next.js uses YAML, talento_it_blog uses Elixir map
   - NimblePublisher can parse YAML with appropriate configuration
   - Or create a script to convert YAML → Elixir map format

3. **Copy images**
   - From: `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/public/images/`
   - To: `/Users/ricardogarciavega/projects/bigardone/phoenix-bigardone.dev/priv/static/images/`

4. **Create projects data**
   - Convert `/Users/ricardogarciavega/projects/bigardone/bigardone.dev/data/projects.js`
   - To Elixir module or JSON file

### Phase 6: SEO & Meta

1. **Add meta tags**
   - Title, description, OpenGraph for each page
   - Twitter card support
   - Consider phoenix_seo library

2. **Add structured data**
   - JSON-LD for blog posts (Article schema)

---

## Code References

### talento_it_blog Files
- `lib/talento_it_blog.ex` - Main content loader with NimblePublisher
- `lib/talento_it_blog/post.ex:1-50` - Post struct definition and build function
- `lib/talento_it_blog/category.ex:1-20` - Category processing
- `lib/talento_it_blog_web/live/home_live.ex` - Homepage with post listing
- `lib/talento_it_blog_web/live/post_live.ex` - Post detail page
- `lib/talento_it_blog_web/seo.ex` - SEO implementation

### bigardone.dev Files
- `components/layout.js` - Main layout wrapper
- `components/header.js` - Navigation header
- `components/footer.js` - Footer with social links
- `components/postCard.js` - Blog post card
- `components/postMeta.js` - Post metadata display
- `components/tags.js` - Tag badges
- `pages/index.js` - Homepage layout
- `pages/blog.js` - Blog listing page
- `pages/blog/[year]/[month]/[day]/[slug].js` - Post detail page
- `tailwind.config.js` - Custom Tailwind configuration
- `css/index.css` - Custom CSS styles
- `data/projects.js` - Projects data
- `src/pageUtils.js` - Utility functions (reading time, date formatting)

---

## Architecture Insights

### Static Content Advantages
- **Zero Database**: All content compiled into application binary
- **Git-friendly**: Markdown files version control naturally
- **Performance**: Content served from memory, no DB queries
- **Type-safe**: Elixir structs ensure data consistency
- **Dev Experience**: Hot reload on markdown file changes

### URL Structure Decision
The Next.js blog uses `/blog/YYYY/MM/DD/slug` while talento_it_blog uses `/:id`.
Recommendation: Use Next.js URL structure for consistency with existing content and better SEO (keeps old URLs working).

### Frontmatter Format
talento_it_blog uses Elixir map syntax, Next.js uses YAML. Options:
1. **Convert to Elixir maps**: More consistent with Phoenix ecosystem
2. **Parse YAML directly**: Use `yaml_elixir` library, less conversion work
Recommendation: Use YAML for easier content migration from Next.js.

---

## Key Differences Between Blogs

| Aspect | talento_it_blog | bigardone.dev |
|--------|-----------------|---------------|
| Framework | Phoenix/LiveView | Next.js |
| Content | Elixir map frontmatter | YAML frontmatter |
| Posts | 222 posts | 100+ posts |
| URL | `/:id` | `/blog/YYYY/MM/DD/slug` |
| Reading time | 200 words/min | 250 words/min |
| Language | Spanish | English |
| Categories | Yes (lists) | No (tags only) |
| Projects | No | Yes |
| Design | Basic | Purple/gray theme |
| Typography | Default | Montserrat/Fira Code |

---

## Open Questions

1. **Frontmatter format**: Convert 100+ posts to Elixir map format or add YAML parsing?
2. **Category handling**: Next.js blog uses only tags - add categories or keep tags only?
3. **Related posts**: Implement or skip for initial version?
4. **Projects section**: Static data or make it configurable?
5. **RSS feed**: Needed for initial launch?
6. **Search**: Client-side search or skip?
7. **Comments**: Integration with external service (e.g., Giscus)?

---

## Next Steps

1. Start with Phase 1: Add dependencies and font configuration
2. Create Post struct adapting from talento_it_blog
3. Build layout components matching bigardone.dev design
4. Create LiveViews for home, blog listing, and post detail
5. Migrate content from Next.js blog
6. Test and refine styling
