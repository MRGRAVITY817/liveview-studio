defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    # Since each sorting keys should be atoms,
    # should convert string->atom
    sort_by =
      (params["sort_by"] || "id")
      |> String.to_atom()

    sort_order =
      (params["sort_order"] || "asc")
      |> String.to_atom()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order
    }

    donations = Donations.list_donations(options)

    socket = assign(socket, donations: donations, options: options)
    {:noreply, socket}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end
end
