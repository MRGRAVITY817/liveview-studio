defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # This happens on page mounts (starts)
  def mount(_params, _session, socket) do
    # LiveView states are stored in `socket`
    socket =
      assign(
        socket,
        brightness: 10,
        brightness_slider: 10,
        temp: "3000"
      )

    # should return this tuple
    {:ok, socket}
  end

  def render(assigns) do
    # HTML + EEX
    # assigns.brightness == @brightness (syntactic sugar)
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light" phx-window-keyup="change-brightness">
      <div class="meter">
        <span style={"
          width: #{@brightness}%;
          background: #{temp_color(@temp)};
        "}>
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
      <form phx-change="change-temp">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                type="radio"
                name="temp"
                id={temp}
                value={temp}
                checked={temp == @temp}
              />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>

      <div class="mt-32">
        <form phx-change="slide-brightness">
          <input
            type="range"
            min="0"
            max="100"
            name="brightness_slider"
            value={@brightness_slider}
            phx-debounce="250"
          />
        </form>
      </div>
    </div>
    """
  end

  defp brightness_up(socket) do
    update(socket, :brightness, &min(&1 + 10, 100))
  end

  defp brightness_down(socket) do
    update(socket, :brightness, &max(&1 - 10, 0))
  end

  def handle_event("change-brightness", %{"key" => "ArrowUp"}, socket) do
    {:noreply, brightness_up(socket)}
  end

  def handle_event("change-brightness", %{"key" => "ArrowDown"}, socket) do
    {:noreply, brightness_down(socket)}
  end

  def handle_event("change-brightness", _, socket) do
    {:noreply, socket}
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

  def handle_event("slide-brightness", params, socket) do
    %{"brightness_slider" => bs} = params

    {:noreply, assign(socket, brightness_slider: String.to_integer(bs))}
  end

  def handle_event("change-temp", %{"temp" => temp}, socket) do
    {:noreply, assign(socket, temp: temp)}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
