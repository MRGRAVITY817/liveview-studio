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

  defp simple_presence_map(presences) do
    Enum.into(
      presences,
      %{},
      fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end
    )
  end

  def list_users(topic) do
    list(topic) |> simple_presence_map
  end

  def update_user(user, topic, update_info) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)
    new_meta = Map.merge(meta, update_info)

    update(self(), topic, user.id, new_meta)
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  defp remove_presences(socket, leaves) do
    simple_presence_map(leaves)
    |> Enum.reduce(socket, fn {user_id, _}, socket ->
      Phoenix.Component.update(socket, :presences, &Map.delete(&1, user_id))
    end)
  end

  defp add_presences(socket, joins) do
    simple_presence_map(joins)
    |> Enum.reduce(socket, fn {user_id, meta}, socket ->
      Phoenix.Component.update(socket, :presences, &Map.put(&1, user_id, meta))
    end)
  end
end
