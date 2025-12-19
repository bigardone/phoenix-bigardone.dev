defmodule BigardoneDevWeb.Layouts do
  @moduledoc """
  Layout components for the bigardone.dev site.
  """
  use BigardoneDevWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_path, :string, default: "/"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-screen flex-col">
      <.site_header current_path={@current_path} />
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

  def site_header(assigns) do
    ~H"""
    <header class="mx-auto w-full max-w-6xl px-4">
      <div class="flex flex-row items-center justify-between py-6">
        <div class="flex-1">
          <.link navigate="/">
            <img src={~p"/images/logo.svg"} width="70" height="50" alt="bigardone.dev" />
          </.link>
        </div>
        <nav class="flex flex-1 flex-row">
          <ul class="flex w-full flex-row justify-end gap-x-4 text-sm">
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
    active? =
      assigns.current_path == assigns.href or
        (assigns.href == "/blog" and String.starts_with?(assigns.current_path, "/blog"))

    assigns = assign(assigns, :active?, active?)

    ~H"""
    <.link
      navigate={@href}
      class={[
        "block font-black text-black transition-colors hover:text-purple-600",
        @active? && "text-purple-900"
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer class="bg-gray-50 pt-2 pb-6 text-gray-600 md:pt-0 md:pb-12">
      <div class="mx-auto flex w-full max-w-6xl flex-row justify-between px-4 align-middle text-sm">
        <div class="w-3/5 md:w-9/12">
          bigardone.dev &copy; {DateTime.utc_now().year}
        </div>
        <div class="flex w-2/5 flex-row justify-end gap-x-10 md:w-2/12">
          <a class="block flex-1 text-right" href="https://github.com/bigardone" target="_blank">
            <img src={~p"/images/github.svg"} width="24" height="24" alt="GitHub" />
          </a>
          <a class="block flex-1 text-right" href="https://twitter.com/bigardone" target="_blank">
            <img src={~p"/images/twitter.svg"} width="24" height="24" alt="Twitter" />
          </a>
          <a
            class="block flex-1 text-right"
            href="https://www.linkedin.com/in/ricardogarciavega/"
            target="_blank"
          >
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
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320" class={@flip && "rotate-180"}>
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

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="size-3 ml-1 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="size-3 ml-1 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
