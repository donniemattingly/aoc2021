defmodule Utils.CircularList do
  def new() do
    {[], []}
  end

  def new(list) when is_list(list) do
    {[], list}
  end

  def current({_, [cur | _]}), do: cur

  def next(cll, times) do
    1..times
    |> Enum.reduce(cll, fn _, acc -> next(acc) end)
  end

  def next({prev, [l]}) do
   {[], Enum.reverse([l |prev])}
  end

  def next({prev, [h | t]}), do: {[h | prev], t}

  def prev({[], next}) do
    [h | t] = Enum.reverse(next)
    {t, [h]}
  end

  def prev({[h | t], next}), do: {t, [h | next]}

  @doc """
  We assume index 0 is the starting element of the list, so to get the nth element:
    - if n > len(prev) we can find the element at n - len(prev) in the next list
    - if n < len(prev) we can find the element at len(prev) - (n + 1)
  """
  def at({prev, next}, index) do
    prev_len = Enum.count(prev)

    cond do
      index >= prev_len -> Enum.at(next, index - prev_len)
      index < prev_len -> Enum.at(prev, prev_len - (index + 1))
    end
  end

  def pop_n(cll, n), do: do_pop_n(cll, n, &pop/1, &Enum.reverse/1)
  def pop_left_n(cll, n), do: do_pop_n(cll, n, &pop_left/1, & &1)

  defp do_pop_n(cll, n, pop_fn, transform_fn) do
    {popped, rest} =
      1..n
      |> Enum.reduce({[], cll}, fn _, {popped, cll} ->
        {e, l} = pop_fn.(cll)
        {[e | popped], l}
      end)

    {transform_fn.(popped), rest}
  end

  def pop(cll = {_, []}), do: next(cll) |> pop_left()
  def pop({prev, [h | t]}), do: {h, {prev, t}}

  def pop_left(cll = {[], _}), do: prev(cll) |> pop()
  def pop_left({[h | t], next}), do: {h, {t, next}}

  def push(cll, val) when is_list(val), do: do_push_n(cll, val, &push/2, &Enum.reverse/1)
  def push({prev, next}, val), do: {prev, [val | next]}

  def push_left(cll, val) when is_list(val), do: do_push_n(cll, val, &push_left/2, & &1)
  def push_left({prev, next}, val), do: {[val | prev], next}

  defp do_push_n(cll, items, push_fn, transform_fn) do
    items
    |> transform_fn.()
    |> Enum.reduce(cll, fn x, acc ->
      push_fn.(acc, x)
    end)
  end

  def to_list({prev, next}) do
    Enum.reverse(prev) ++ next
  end

  def at_end?({prev, next}), do: next == []

  def size({prev, next}), do: Enum.count(prev) + Enum.count(next)

  @doc """
  traverses list until either the fun returns a truthy value or a complete circle has been made
  """
  def next_until(list, fun), do: do_traverse_until(list, fun, &next/1, 0, size(list))
  def prev_until(list, fun), do: do_traverse_until(list, fun, &prev/1, 0, size(list))

  defp do_traverse_until(list, fun, traverse_fun, index, size) do
    IO.inspect(list)
    cond do
      # at_end?(list) -> list |> traverse_fun.() |> do_traverse_until(fun, traverse_fun, index, size)
      fun.(current(list)) -> list
      index >= size -> nil
      true -> list |> traverse_fun.() |> do_traverse_until(fun, traverse_fun, index + 1, size)
    end
  end
end
