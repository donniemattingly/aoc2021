defmodule Utils.Graph do
  use Memoize

  @doc """
  Performs a breadth first search starting at `node` The neighbors for `node` are determined
  by `neighbors_fn`. Becomes a BFS for weights_fn always returning 1 (or whatever, as long as it's the same)

  From wikipedia, a BFS is:

      1  procedure BFS(G,start_v):
      2      let Q be a queue
      3      label start_v as discovered
      4      Q.enqueue(start_v)
      5      while Q is not empty
      6          v = Q.dequeue()
      7          if v is the goal:
      8              return v
      9          for all edges from v to w in G.adjacentEdges(v) do
      10             if w is not labeled as discovered:
      11                 label w as discovered
      12                 w.parent = v
      13                 Q.enqueue(w)

  but the challenge is to accomplish this w/ recursion

  The data structures we'll need to keep around are a queue, a map of discovered nodes, the current path

  We can overload the last two as a single map, with the map being from node -> parent, where existing in
  the map indicates a node is discovered. The initial node with have a value of :start to indicate it has no parent

  We'll also take a function of v to return edges
  """
  def dijkstra(cur_node, neighbors_fn, weights_fn) do
    queue = PriorityQueue.new() |> PriorityQueue.push(cur_node, 1)
    discovered = Map.new() |> Map.put(cur_node, :start)

    do_dijkstra(neighbors_fn, weights_fn, queue, discovered, %{})
  end

  @doc """
  BFS is just Dijkstra with constant weights
  """
  def bfs(cur_node, neighbors_fn) do
    dijkstra(cur_node, neighbors_fn, fn _ -> 1 end)
  end

  def do_dijkstra(neighbors_fn, weights_fn, queue, discovered, known) do
    case PriorityQueue.pop(queue) do
      {:empty, _} ->
        discovered
      {{:value, v}, new_queue} ->
        case Map.get(known, v) do
          nil -> {updated_queue, updated_discovered} =
                   neighbors_fn.(v)
                   |> Enum.reduce({new_queue, discovered}, fn w, {q, d} ->
                     case Map.has_key?(d, w) do
                       true -> {q, d}
                       false -> {PriorityQueue.push(q, w, weights_fn.(v, w)), Map.put(d, w, v)}
                     end
                   end)

                 if :rand.uniform() > 0.9999 do
                   updated_discovered |> get_path(v) |> length |> to_string |> IO.puts()
                 end

                 do_dijkstra(neighbors_fn, weights_fn, updated_queue, updated_discovered, Map.put(known, v, {updated_queue, updated_discovered}))
          {q, d} -> do_dijkstra(neighbors_fn, weights_fn, q, d, known)
        end
    end
  end

  @doc """
  Given a `map` of cur_nodes to parents (as a result of performing `Utils.Graph.bfs/2`) returns the path
  from goal to the start (or a node with no parent).
  """
  def get_path(map, goal) do
    get_path(map, goal, [])
  end

  defp get_path(map, current_node, path) do
    case Map.get(map, current_node) do
      nil -> path
      x -> get_path(map, x, [current_node | path])
    end
  end

  def start_to_goal(path, goal) do
    start_to_goal(path, goal, [])
  end

  defp start_to_goal(path, :start, path_list) do
    path_list
  end

  defp start_to_goal(path, cur_node, path_list) do
    next = Map.get(path, cur_node)
    start_to_goal(path, next, [next | path_list])
  end

end
