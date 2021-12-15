defmodule Day15 do
  use Utils.DayBoilerplate, day: 15

  def sample_input do
    """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_and_parse_lines(
         fn l ->
           l
           |> Utils.split_each_char
           |> Enum.map(&String.to_integer/1)
         end
       )
    |> Utils.list_of_lists_to_map_by_point()
  end

  def solve4(input) do
    goal = input
           |> Map.to_list
           |> Enum.map(&elem(&1, 0))
           |> Enum.max
    paths = Utils.Graph.dijkstra({0, 0}, &neighbor_for_point(input, &1), &weight_for_point(input, &1, &2))

    [start | rest] = Utils.Graph.get_path(paths, goal)

    paths
    |> IO.inspect
    rest
    |> Enum.map(&Map.get(input, &1))
    |> IO.inspect
    |> Enum.sum()
  end

  def solve(input) do
    g = make_graph(input)
    goal = Map.keys(input)
           |> Enum.max
    path = Graph.dijkstra(g, {0, 0}, goal)

    cost = path
           |> Enum.map(&Map.get(input, &1))
           |> Enum.sum

    cost - Map.get(input, {0, 0})
  end

  def make_graph(input) do
    edges = input
            |> Map.keys()
            |> Enum.flat_map(
                 fn p ->
                   Day15.neighbor_for_point(input, p)
                   |> Enum.map(&{p, &1})
                 end
               )
            |> Enum.map(fn {v, w} -> {v, w, Map.get(input, w)} end)
            |> Enum.map(fn {a, b, w} -> Graph.Edge.new(a, b, weight: w) end)

    Graph.new()
    |> Graph.add_edges(edges)
  end

  def neighbor_for_point(map, {x, y}) do

    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(
         fn
           {dx, dy} -> {x + dx, y + dy}
         end
       )
    |> Enum.filter(fn p -> Map.has_key?(map, p) end)
  end

  def get_tiled_pos(tile_size, pos) do
    {div(pos, tile_size + 1), rem(pos, tile_size + 1)}
  end

  def get_tiled_point(map, {x, y}) do
    {chunk_size, _} = Map.keys(map)
                      |> Enum.max()

    {get_tiled_pos(chunk_size, x), get_tiled_pos(chunk_size, y)}
  end

  def in_expanded_map?(map, point) do
    {{tx, ix}, {ty, iy}} = get_tiled_point(map, point)
    Map.has_key?(map, {ix, iy}) and (tx < 5 and ty < 5)
  end

  def weight_for_point(map, from, point), do: Map.get(map, point)
end
