defmodule Circle.Node do
  @moduledoc """
  An wrapper around state for a node in circular list. The Node struct prev and next
  are pids for agents of other nodes
  """
  use Agent

  defstruct prev: nil, value: nil, next: nil

  def start_link(node) do
    Agent.start_link(fn -> node end)
  end

  def get(pid) do
    Agent.get(pid, & &1)
  end

  def set_prev(pid, prev) do
    Agent.update(pid, fn x -> %{x | prev: prev} end)
  end

  def set_next(pid, next) do
    Agent.update(pid, fn x -> %{x | next: next} end)
  end

  def value(pid), do: Agent.get(pid, & &1.value)
  def next(pid), do: Agent.get(pid, & &1.next)
  def prev(pid), do: Agent.get(pid, & &1.prev)

  def link(first, second) do
    set_next(first, second)
    set_prev(second, first)
  end
end
