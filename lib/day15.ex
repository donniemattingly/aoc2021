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

  def solve(input) do
    g = make_graph(input)
        |> IO.inspect
    goal = Graph.vertices(g)
           |> Enum.max
           |> IO.inspect

    path = Graph.dijkstra(g, {0, 0}, goal)

    cost = path
           |> Enum.map(&weight_for_point(input, &1))
           |> IO.inspect
           |> Enum.sum

    cost - Map.get(input, {0, 0})
  end

  def make_graph(input) do
    chunk_size = input
                 |> Map.keys
                 |> Enum.max
                 |> elem(0)
                 |> Kernel.+(1)
                 |> IO.inspect
    edges = input
            |> Map.keys()
            |> Stream.flat_map(
                 fn {x, y} -> for dx <- 0..4, dy <- 0..4, do: {x + dx * chunk_size, y + dy * chunk_size} end
               )
            |> Stream.flat_map(
                 fn p ->
                   Day15.neighbor_for_point(input, p, chunk_size)
                   |> Enum.map(&{p, &1})
                 end
               )
            |> Stream.map(fn {v, w} -> {v, w, weight_for_point(input, w)} end)
            |> Stream.map(fn {a, b, w} -> Graph.Edge.new(a, b, weight: w) end)
            |> Enum.to_list

    Enum.count(edges)
    |> IO.inspect(label: "edges count")

    Graph.new()
    |> Graph.add_edges(edges)
  end

  def neighbor_for_point(map, {x, y}, chunk_size) do
    max = chunk_size * 5
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(
         fn
           {dx, dy} -> {x + dx, y + dy}
         end
       )
    |> Enum.filter(fn {x, y} -> (x < max and y < max) and (x >= 0 and y >= 0) end)
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

  def weight_for_point(map, point) do
    {{tx, ix}, {ty, iy}} = get_tiled_point(map, point)
    original = Map.get(map, {ix, iy})
    new = original + tx + ty
    if new > 9, do: rem(new, 10) + 1, else: new
  end
end
