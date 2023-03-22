defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  attr :expiration, :integer, default: 24
  attr :minutes, :integer
  slot :legal
  slot :inner_block, required: true

  def promo(assigns) do
    # `assign_new` will create an assign if `minutes` attr is not given.
    assigns = assign_new(assigns, :minutes, fn -> assigns.expiration * 60 end)

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">Deal expires in <%= @minutes %> minutes</div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end
end
