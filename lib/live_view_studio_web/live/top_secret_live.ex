defmodule LiveViewStudioWeb.TopSecretLive do
  use LiveViewStudioWeb, :live_view

  # Redirection is done via websocket, which means it doesn't go through router pipeline.
  # We should do manual check using `on_mount()` hook when this page is reached from websocket.
  on_mount {LiveViewStudioWeb.UserAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="top-secret">
      <img src="/images/spy.svg" />
      <div class="mission">
        <h1>Top Secret</h1>
        <h2>Your Mission</h2>
        <h3><%= pad_user_id(@current_user) %></h3>
        <p>
          Storm the castle and capture 3 bottles of Elixir.
        </p>
      </div>
    </div>
    """
  end

  def pad_user_id(user) do
    user.id
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end
end
