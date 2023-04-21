defmodule LiveViewStudioWeb.PresenceLive do
  alias LiveViewStudioWeb.Presence
  use LiveViewStudioWeb, :live_view

  @topic "users:video"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      # track current process(= user)
      {:ok, _} =
        Presence.track(self(), @topic, current_user.id, %{
          username: current_user.email |> String.split("@") |> hd(),
          is_playing: false
        })
    end

    presences = Presence.list(@topic)

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, presences)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <pre>
    <%= inspect(@presences, pretty: true) %>
    </pre>
    <div id="presence">
      <div class="users">
        <h2>Who's Here?</h2>
        <ul></ul>
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

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)
    {:noreply, socket}
  end
end
