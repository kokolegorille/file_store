defmodule FileStore do
  @moduledoc """
  Documentation for `FileStore`.
  """

  def store(id, type, path, filename) do
    file_info = get_file_info(path)
    if ensure_file_mime_type(filename, file_info["content_type"]) do
      {:ok, Map.merge(do_store(id, type, path, filename), file_info)}
    else
      {:error, :invalid_content_type}
    end
  end

  def store!(id, type, path, filename) do
    file_info = get_file_info(path)
    if ensure_file_mime_type(filename, file_info["content_type"]) do
      Map.merge(do_store(id, type, path, filename), file_info)
    else
      raise "Uploaded file has wrong MIME type"
    end
  end

  # Private

  defp do_store(id, type, path, filename) do
    dest = Path.join([uploads_directory(), type, id, filename])
      dirname = Path.dirname(dest)
      unless File.exists?(dirname), do: File.mkdir_p!(dirname)

      File.cp!(path, dest)

      %{
        "id" => id,
        "filename" => filename,
        "type" => type,
        "path" => dest,
        "hash" => do_hash_file(dest)
      }
  end

  defp ensure_file_mime_type(filename, content_type) do
    # Ensure the file extension returns the MIME type detected by file_info
    content_type == filename
    |> Path.extname()
    |> String.trim_leading(".")
    |> MIME.type()
  end

  defp get_file_info(filename) do
    size = File.lstat!(filename).size

    file_mime = filename
    |> FileInfo.get_info()
    |> Map.get(filename)

    content_type = "#{file_mime.type}/#{file_mime.subtype}"

    %{
      "size" => size,
      "content_type" => content_type
    }
  end

  defp do_hash_file(file_path) do
    hash_ref = :crypto.hash_init(:sha256)

    file_path
    |> File.stream!()
    |> Enum.reduce(hash_ref, fn chunk, prev_ref->
      new_ref = :crypto.hash_update(prev_ref, chunk)
      new_ref
    end)
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  defp uploads_directory do
    Application.get_env(:file_store, :storage_dir_prefix)
  end
end
