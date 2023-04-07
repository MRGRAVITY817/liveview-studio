defmodule LiveViewStudioWeb.ServerFormComponent do
  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  use LiveViewStudioWeb, :live_component

  def mount(socket) do
    # Create empty `Server` struct
    changeset = Servers.change_server(%Server{})
    {:ok, assign(socket, :form, to_form(changeset))}
  end
end
