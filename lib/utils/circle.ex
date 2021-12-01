defmodule Circle do
  @moduledoc """
  A circular list. Nodes are individual agents.
  """

  alias Circle.Node, as: N

  def new(values) do
    nodes = values
    |> Enum.map(fn node ->
      {:ok, pid} = N.start_link(%N{value: node})
      pid
    end)

    circle = nodes
    |> Enum.chunk_every(3, 1)
    |> Enum.filter(fn x -> Enum.count(x) == 3 end)
    |> Enum.reduce(%{}, fn [prev, node, next], acc ->
      N.link(prev, node)
      N.link(node, next)
      Map.put(acc, N.value(node), node)
    end)

    [first, second | _] = nodes
    [last, second_last | _] = Enum.reverse(nodes)

    N.link(first, second)
    N.link(last, first)
    N.link(second_last, last)

    circle
    |> Map.put(N.value(first), first)
    |> Map.put(N.value(last), last)
  end

 def pop_next_3(circle, label) do
    a = circle[label] |> N.next()
    b = a |> N.next()
    c = b |> N.next()
    d = c |> N.next()

    popped = [a, b, c]

    N.link(N.prev(a), d)

    new_circle = popped |> Enum.reduce(circle, fn x, acc -> Map.delete(acc, N.value(x)) end)
    {popped, new_circle}
  end

  def insert(circle, label, [a, b, c]) do
    current = circle[label]

    next = N.next(current)
    N.link(current, a)
    N.link(c, next)

    circle
    |> Map.put(N.value(a), a)
    |> Map.put(N.value(b), b)
    |> Map.put(N.value(c), c)
  end
end
