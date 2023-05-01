defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def track_user(user, topic, meta) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
    # track current process(= user)
    {:ok, _} =
      track(
        self(),
        topic,
        user.id,
        Map.merge(
          %{username: user.email |> String.split("@") |> hd()},
          meta
        )
      )
  end

  def update_user(user, topic, update_info) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)
    new_meta = Map.merge(meta, update_info)

    update(self(), topic, user.id, new_meta)
  end
end
