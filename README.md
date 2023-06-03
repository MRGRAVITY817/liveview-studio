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

- `replace`: (default) Replaces the element with the contents
- `ignore`: will ask DOM to ignore this part when rerendering
- `stream`: supports stream operations. Streams are used to manage large collections in the UI without having to store the collection on the server
  
More in [here](https://hexdocs.pm/phoenix_live_view/dom-patching.html).

### Add JS hooks

We can use JS libraries, by configuring `hooks` in `app.js` file.

```js
// ...

const Hooks = {
  CustomHook: {
    mounted() {
      const hookedElement = this.el
      // Use JS libraries 
      // or
      // Do some valid JS stuffs like using clipboard!
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks, 
})

// ...
```

Then _hook_ the liveview DOM element, using `phx-hook` attribute.

```html
<div phx-update="ignore" id="wrapper">
  <div
    id="custom-hook-id"
    phx-hook="CustomHook"    
  >
  </div>
</div>
```

`mounted()` callback is one of the _life-cycle callbacks_.   
Here's the [full list](https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook) of them.

* `mounted` - the element has been added to the DOM and its server LiveView has finished mounting
* `beforeUpdate` - the element is about to be updated in the DOM. Note: any call here must be synchronous as the operation cannot be deferred or cancelled.
* `updated` - the element has been updated in the DOM by the server
* `destroyed` - the element has been removed from the page, either by a parent update, or by the parent being removed entirely
* `disconnected` - the element's parent LiveView has disconnected from the server
* `reconnected` - the element's parent LiveView has reconnected to the server

### Key events

```html
  <input
    type="number"
    value={@current}
    phx-keyup="set-current"
    phx-key="Enter"
  />
```

This will send the `value` to `set-current` event, only when `Enter` key is pressed


```html
  <div id="juggling" phx-window-keyup="update">
```

This will listen to all the key up events.

### Using `metadata` field in `LiveSocket` to extend event property

By adding this code in `app.js`,

```javascript
let liveSocket = new LiveSocket("/live", Socket, {
  // ...
  metadata: {
    keydown: (e, el) => {
      return {
        key: e.key,
        shiftKey: e.shiftKey
      }
    }
  }
});
```

We can now get `shift key` event from `phx-keydown`.

```elixir
def handle_event("an-event", %{"key" => key, "shiftKey" => shiftKey}, socket) do
  {:noreply, socket}
end
```

### `phx-throttle`
Similar to `phx-debounce`, yet it first emits the event and then limits the rate. Useful when user is pressing down the key, and we don't want event to be emitted to quickly.

```html
<div id="donations" phx-window-keydown="paginate" phx-throttle="200">
```

### Image input & Drag and Drop

LiveView provides a helper component called `live_file_input`.

```html
<.live_file_input upload={@uploads.photos} />
```

Wanna support drag and drop? Wrap with div element that has `phx-drop-target` attribute.

```html
<div class="drop" phx-drop-target={@uploads.photos.ref}>
  <.live_file_input upload={@uploads.photos} />
</div>
```

### Image Preview

It's easy to show image preview for uploading image - use `.live_img_preview`.   

(`width` attribute is mandatory, like Next.js Image component)

```html
<.live_img_preview entry={entry} width="75"> <>
```

### How do we handle with _ready-to-upload_ files?

First of all, those kind of files are called _Entries_ in Phoenix.  

`consume_uploaded_entry` function will _consume(upload to server, cloud storage, etc)_ the entries that are still in progress (living in browser).  

```elixir
photo_locations =
  consume_uploaded_entries(socket, :photos, fn meta, entry ->
    dest =
      Path.join([
        "priv",
        "static",
        "uploads",
        "#{entry.uuid}-#{entry.client_name}"
      ])

    File.cp!(meta.path, dest)

    url_path = static_path(socket, "/uploads/#{Path.basename(dest)}")

    {:ok, url_path}
  end)
```