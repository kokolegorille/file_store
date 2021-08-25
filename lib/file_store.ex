defmodule FileStore do
  @moduledoc """
  Documentation for `FileStore`.
  """

  def store(id, type, path, filename) do
    dest = Path.join([uploads_directory(), type, id, filename])
    File.mkdir_p!(Path.dirname(dest))

    File.cp!(path, dest)

    %{
      "id" => id,
      "filename" => filename,
      "type" => type,
      "path" => dest,
      "hash" => hash_file(dest)
    }
    |> Map.merge(file_info(dest))
  end

  # Private

  defp file_info(filename) do
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

  defp hash_file(file_path) do
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
