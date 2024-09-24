defmodule Rumbl.Multimedia.Permalink do
  @behaviour Ecto.Type

  def type() do
    :id
  end

  # When ID is a string like "/10-the-video-slug"
  def cast(permalink) when is_binary(permalink) do
    case Integer.parse(permalink) do
      {int, _str_remainder} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  # When ID is numeric. Like 10.
  def cast(id) when is_integer(id) do
    {:ok, id}
  end

  def cast(_) do
    :error
  end

  # When saving data to the database.
  # When id is numeric like 10.
  def dump(id) when is_integer(id) do
    {:ok, id}
  end

  # When loading from the database.
  # When the ID is numeric like 10.
  def load(id) when is_integer(id) do
    {:ok, id}
  end
end
