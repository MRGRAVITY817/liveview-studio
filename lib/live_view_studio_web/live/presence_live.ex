defmodule LiveViewStudioWeb.PresenceLive do
  alias LiveViewStudioWeb.Presence
  use LiveViewStudioWeb, :live_view

  @topic "users:video"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, @topic)
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
      |> assign(:presences, simple_presence_map(presences))
      |> assign(:diff, nil)

    {:ok, socket}
  end

  def simple_presence_map(presences) do
    Enum.into(
      presences,
      %{},
      fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end
    )
  end

  def render(assigns) do
    ~H"""
    <pre><%= inspect(@diff, pretty: true) %></pre>
    <div id="presence">
      <div class="users">
        <h2>Who's Here?</h2>
        <ul>
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

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)
    %{current_user: current_user} = socket.assigns
    %{metas: [meta | _]} = Presence.get_by_key(@topic, current_user.id)
    new_meta = %{meta | is_playing: socket.assigns.is_playing}

    Presence.update(self(), @topic, current_user.id, new_meta)

    {:noreply, socket}
  end

  # presence_diff contains the change of joins/leaves in presence
  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket =
      socket
      |> remove_presences(diff.leaves)
      |> add_presences(diff.joins)

    {:noreply, socket}
  end

  defp remove_presences(socket, leaves) do
    simple_presence_map(leaves)
    |> Enum.reduce(socket, fn {user_id, _}, socket ->
      update(socket, :presences, &Map.delete(&1, user_id))
    end)
  end

  defp add_presences(socket, joins) do
    simple_presence_map(joins)
    |> Enum.reduce(socket, fn {user_id, meta}, socket ->
      update(socket, :presences, &Map.put(&1, user_id, meta))
    end)
  end
end
