defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)
    donation_count = Donations.count_donations()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)

    socket =
      assign(
        socket,
        donations: donations,
        options: options,
        donation_count: donation_count
      )

    {:noreply, socket}
  end

  defp more_pages?(options, donation_count) do
    options.page * options.per_page < donation_count
  end

  defp pages(options, donation_count) do
    page_count = ceil(donation_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end

  ######## Event handlers #########

  def handle_event("paginate", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, goto_page(socket, socket.assigns.options.page - 1)}
  end

  def handle_event("paginate", %{"key" => "ArrowRight"}, socket) do
    {:noreply, goto_page(socket, socket.assigns.options.page + 1)}
  end

  def handle_event("paginate", _, socket), do: {:noreply, socket}

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    # `push_patch` runs `patch` from server-side.
    # When `push_patch` runs, it invokes `handle_params`.
    socket = push_patch(socket, to: ~p"/donations?#{params}")

    {:noreply, socket}
  end

  ########### Helper functions ###########

  defp goto_page(socket, page) when page > 0 do
    params = %{socket.assigns.options | page: page}

    # invokes patch => handle params
    push_patch(socket, to: ~p"/donations?#{params}")
  end

  defp goto_page(socket, _page), do: socket

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
      <%= render_slot(@inner_block) %>
      <%= sort_indicator(@sort_by, @options) %>
    </.link>
    """
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_, _), do: ""

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(item quantity days_until_expires) do
    # Since the number of atom is limited per program,
    # we need to make exception error when user is making too much atoms.
    # ex) DDOS attack
    String.to_existing_atom(sort_by)
  end

  # If the route param isn't one of [item quantity days_until_expires],
  # just sort it by row id.
  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_existing_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc
end
