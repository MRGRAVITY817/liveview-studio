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
      <button phx-click="off">
        <img src="/images/light-off.svg" alt="Light off" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" alt="Light down" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" alt="Light up" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" alt="Light on" />
      </button>
      <button phx-click="fire">
        <img src="/images/fire.svg" alt="Fire" />
      </button>
    </div>
    """
  end

  # Pattern matching for `handle_event` from `phx-click` binding
  def handle_event("off", _, socket) do
    # `assign` sets the value to state.
    socket = assign(socket, brightness: 0)

    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    # `update` sets the value to state, using the previous state value.
    # `&max(&1 - 10, 0)` == `fn(x) -> max(x - 10, 100)
    socket = update(socket, :brightness, &max(&1 - 10, 0))

    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    # `&min(&1 - 10, 0)` == `fn(x) -> min(x + 10, 0)
    socket = update(socket, :brightness, &min(&1 + 10, 100))

    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, brightness: 100)

    {:noreply, socket}
  end

  def handle_event("fire", _, socket) do
    socket = assign(socket, :brightness, Enum.random(0..100))

    {:noreply, socket}
  end
end
