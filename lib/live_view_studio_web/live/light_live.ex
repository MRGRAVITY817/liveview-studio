defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # This happens on page mounts (starts)
  def mount(_params, _session, socket) do
    # LiveView states are stored in `socket`
    socket = assign(socket, brightness: 10)

    # should return this tuple
    {:ok, socket}
  end

  def render(assigns) do
    # HTML + EEX
    # assigns.brightness == @brightness (syntactic sugar)
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </span>
      </div>
    </div>
    """
  end
end
