# LiveViewStudio

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: <https://www.phoenixframework.org/>
  * Guides: <https://hexdocs.pm/phoenix/overview.html>
  * Docs: <https://hexdocs.pm/phoenix>
  * Forum: <https://elixirforum.com/c/phoenix-forum>
  * Source: <https://github.com/phoenixframework/phoenix>


## What I learned

### JS commands

There are many reasons to use [JS commands](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.JS.html), 
but the most common reason is to change client-side UI without reaching server.   
Hence, we don't have to create unnecessary websocket connections.  

Here are the most commonly used ones:
- `JS.hide()`, `JS.show()`, `JS.toggle()`: used for showing/hiding certain DOM element. Useful for modals and sidebars.
- `JS.push(event_name, info_to_deliver)`: it augments additional functionality when using with `phx-*` bindings, 
```elixir
      <button
        phx-click={
          JS.push("add-product", value: %{product: product.image}) <- `value`
          |> JS.transition("shake", to: "#cart-button", time: 500)
        }
        phx-value-product={product.image} <- phx-`value`-product
      >
        Add
      </button>
```
