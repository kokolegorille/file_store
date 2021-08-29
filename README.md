# FileStore

Simple local storage.

It is not intended to be used in the cloud, but it plays well with live_file_upload.

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

## Dependencies

{:file_info, "~> 0.0.4"},

## API

Only one function

path: the temp file path
dest: the destination directory
filename: the original filename

## Function

```
def store(path, dest, filename) do
  ...
end
```

It returns a plain map

```
    %{
      "filename" => string,
      "content_type" => string,
      "path" => string,
      "size" => int,
    }
```

## How to use with live file uploads

Here is an example... in a live view form component

```
  defp do_consume_entries(socket, key) when key in ~w(medium thumbnail)a do
    consume_uploaded_entries(socket, key, fn %{path: path} = _meta, entry ->
      id = get_id_from_socket(socket)
      # Transform key to string for file_store
      key = to_string(key)
      # Use your own way to generate destination dir from id and key!
      dest = generate_dest(id, key)

      file = FileStore.store(path, dest, entry.client_name)
      file["path"]
    end)
  end

  defp generate_dest(id, key) do
    Path.join([uploads_directory(), key, id])
  end

  defp uploads_directory do
    Application.get_env(:your_app4, :storage_dir_prefix)
  end
```

You need to set storage_prefix_dir in your config.