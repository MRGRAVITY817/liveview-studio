defmodule LiveViewStudioWeb.ServerFormComponent do
  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  use LiveViewStudioWeb, :live_component

  def mount(socket) do
    # Create empty `Server` struct
    changeset = Servers.change_server(%Server{})
    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="field">
          <.input
            field={@form[:name]}
            placeholder="Server Name"
            phx-debounce="200"
          />
        </div>
        <div class="field">
          <.input field={@form[:framework]} placeholder="Framework" />
        </div>
        <div class="field">
          <.input
            field={@form[:size]}
            type="number"
            placeholder="Size (MB)"
          />
        </div>
        <.button phx-disable-with="Saving...">
          Save
        </.button>
        <.link class="cancel" patch={~p"/servers"}>
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket = push_patch(socket, to: ~p"/servers/#{server.id}")
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
end
