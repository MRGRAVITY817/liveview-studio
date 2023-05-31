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

### Presence

[`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html) module provides very handy APIs to track/update/etc... with user presences. 
Think about Discord sidebar UI that shows who's currently online in the server.  

It's a genserver and not provided by default, so you have to add it with command `mix phx.gen.presence`.  

Here's methods that I've used from Presence module:
- `track(pid, topic, key, meta)`: Track an arbitrary process as a presence.
- `update(socket, key, meta)`: Update a channel presence's metadata.

** `(pid, topic) = (socket)`


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

### `phx-update` attribute

- `phx-update="ignore"`: will ask DOM to ignore this part when rerendering

### Add JS hooks

We can use JS libraries, by configuring `hooks` in `app.js` file.

```js
// ...

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks, 
})

// ...
```