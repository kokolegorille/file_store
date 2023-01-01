defmodule FileStore do
  @moduledoc """
  Documentation for `FileStore`.

  A super simple local file storage.

  It checks mime type and returns a file_info plain map
  """

  @doc"""
  Store a temp file to dest w/ filename.
  It ensures mime type is correct.
  Returns {:ok, file} | {:error, msg}
  """
  def store(path, dest, filename) do
    content_type = get_content_type(path)
    if ensure_file_mime_type(filename, content_type),
      do: {:ok, new_file(do_store(path, dest, filename), content_type)},
      else: {:error, :invalid_content_type}
  end

  @doc"""
  Store a temp file to dest w/ filename.
  It ensures mime type is correct.
  Returns file or raise
  """
  def store!(path, dest, filename) do
    content_type = get_content_type(path)
    if ensure_file_mime_type(filename, content_type),
      do: new_file(do_store(path, dest, filename), content_type),
      else: raise "Uploaded file has wrong MIME type"
  end

  # Private

  defp new_file(store_info, content_type) do
    Map.put(store_info, "content_type", content_type)
  end

  defp do_store(path, dest, filename) do
    full_path = Path.join([dest, filename])

    unless File.exists?(dest), do: File.mkdir_p!(dest)

    # cp is not efficient and leads to timeout!
    File.rename(path, full_path)

    %{
      "filename" => filename,
      "path" => full_path,
      "size" => File.lstat!(full_path).size,
    }
  end

  defp ensure_file_mime_type(filename, content_type) do
    # Ensure the file extension returns the MIME type detected by file_info
    content_type == filename
    |> Path.extname()
    |> String.trim_leading(".")
    |> MIME.type()
  end

  defp get_content_type(filename) do
    file_mime = filename
    |> FileInfo.get_info()
    |> Map.get(filename)

    "#{file_mime.type}/#{file_mime.subtype}"
  end
end
