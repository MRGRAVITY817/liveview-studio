defmodule LiveViewStudioWeb.PresenceLive do
  alias LiveViewStudioWeb.Presence
  use LiveViewStudioWeb, :live_view

  @topic "users:video"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Presence.track_user(current_user, @topic, %{is_playing: false})
    end

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, Presence.list_users(@topic))
      |> assign(:diff, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <pre>
    <%!-- <%= inspect(@diff, pretty: true) %> --%>
    </pre>
    <div id="presence">
      <div class="users">
        <h2>
          Who's Here?
          <button phx-click={toggle_presences()}>
            <.icon name="hero-list-bullet-solid" />
          </button>
        </h2>
        <ul id="presences">
          <li :for={{_user_id, meta} <- @presences}>
            <span>
              <%= if meta.is_playing, do: "👀", else: "🙈" %>
            </span>
            <span class="username"><%= meta.username %></span>
          </li>
        </ul>
      </div>
      <div class="video" phx-click="toggle-playing">
        <%= if @is_playing do %>
          <.icon name="hero-pause-circle-solid" />
        <% else %>
          <.icon name="hero-play-circle-solid" />
        <% end %>
      </div>
    </div>
    """
  end

  def toggle_presences(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#presences")
    |> JS.remove_class("bg-slate-400", to: ".hero-list-bullet-solid.bg-slate-400")
    |> JS.add_class("bg-slate-400", to: ".hero-list-bullet-solid:not(.bg-slate-400)")
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    Presence.update_user(
      socket.assigns.current_user,
      @topic,
      %{is_playing: socket.assigns.is_playing}
    )

    {:noreply, socket}
  end

  # presence_diff contains the change of joins/leaves in presence
  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end
end
