defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def track_user(current_user, topic, meta) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
    # track current process(= user)
    {:ok, _} =
      track(
        self(),
        topic,
        current_user.id,
        Map.merge(
          %{username: current_user.email |> String.split("@") |> hd()},
          meta
        )
      )
  end
end
