defmodule Utils.Bitwise do
  @moduledoc """
  Functions for manipulating bitstrings
  """

  @doc ~S"""
  Breaks a `binary` in to `n`-length chunks of bits

  ## Examples
      iex> Utils.Bitwise.chunks("abcd", 8)
      ["a", "b", "c", "d"]
  """
  def chunks(binary, n) do
    do_chunks(binary, n, [])
  end

  defp do_chunks(binary, n, acc) when bit_size(binary) <= n do
    Enum.reverse([binary | acc])
  end

  defp do_chunks(binary, n, acc) do
    <<chunk::size(n), rest::bitstring>> = binary
    do_chunks(rest, n, [<<chunk::size(n)>> | acc])
  end
end
