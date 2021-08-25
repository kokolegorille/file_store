# FileStore

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `file_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:file_store, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/file_store](https://hexdocs.pm/file_store).

# Local file_store

It is not intended to be used in the cloud.

But it plays well with live_file_upload.

## dependency

{:file_info, "~> 0.0.4"},

## API

Only one function

id: uuid of resource
type: the field_name
path: the temp file path
filename: the original filename

If the id of the resource is not known before create, use a simple uuid field.

```
  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> ensure_uuid(:uploads_uuid)
    |> validate_required(@required_fields)
  end

  defp ensure_uuid(changeset, field) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, Ecto.UUID.generate())
      _ -> changeset
    end
  end
```

Be sure to get the uuid
```
  defp get_id_from_socket(socket) do
    socket.assigns.event.uploads_uuid || socket.assigns.changeset.changes.uploads_uuid
  end
```

## Function

```
def store(id, type, path, filename) do
  ...
end
```

It returns a plain map

```
    %{
      "id" => uuid,
      "filename" => string,
      "type" => string,
      "path" => string,
      "hash" => string,
      "size" => int,
      "content_type" => string,
    }
```

## Configure

```
config :file_store,
  storage_dir_prefix: "/path/to/uploads"
```

## How to use with live file uploads

Here is an example...

```
  defp do_consume_entries(socket, key) when key in ~w(medium thumbnail)a do
    consume_uploaded_entries(socket, key, fn %{path: path} = _meta, entry ->
      id = get_id_from_socket(socket)

      # Transform key to string for file_store
      file = FileStore.store(id, to_string(key), path, entry.client_name)
      #DomainEvents.store_file(file, socket.assigns.metadata)

      file["path"]
    end)
  end
```

