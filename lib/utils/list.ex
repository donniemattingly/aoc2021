defmodule Utils.List do
  @moduledoc """
  A few functions for manipulating lists
  """

  @doc ~S"""
  Rotates the list `l` by `n` elements left

  ## Examples
      iex> Utils.List.left_rotate([1, 2, 3, 4], 1)
      [2, 3, 4, 1]
  """
  def left_rotate(l, n \\ 1)
  def left_rotate([], _), do: []
  def left_rotate(l, 0), do: l
  def left_rotate([h | t], 1), do: t ++ [h]
  def left_rotate(l, n) when n > 0, do: left_rotate(left_rotate(l, 1), n - 1)
  def left_rotate(l, n), do: right_rotate(l, -n)

  @doc ~S"""
  Rotates the list `l` by `n` elements left

  ## Examples
      iex> Utils.List.right_rotate([1, 2, 3, 4], 1)
      [4, 1, 2, 3]
  """
  def right_rotate(l, n \\ 1)

  def right_rotate(l, n) when n > 0,
    do: Enum.reverse(l) |> Utils.List.left_rotate(n) |> Enum.reverse()

  def right_rotate(l, n), do: left_rotate(l, -n)

  def zip_with_index(list) do
    Enum.zip(list, 0..(length(list) - 1))
  end

  def flatten([head | tail]), do: flatten(head) ++ flatten(tail)
  def flatten([]), do: []
  def flatten(element), do: [element]

  def cartesian([]), do: []
  def cartesian(lists), do: cartesian(Enum.reverse(lists), []) |> Enum.to_list()

  defp cartesian([], elems), do: [elems]

  defp cartesian([h | tail], elems) do
    Stream.flat_map(h, fn x -> cartesian(tail, [x | elems]) end)
  end
end
