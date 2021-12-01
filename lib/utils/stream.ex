defmodule Utils.Stream do

  def pop(stream) do
    stream
    |> Stream.take(1)
    |> Enum.to_list
    |> hd
  end
end
