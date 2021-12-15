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
    goal = input |> Map.to_list |> Enum.map(&elem(&1, 0)) |> Enum.max
    paths = Utils.Graph.dijkstra({0,0}, &neighbor_for_point(input, &1), fn _, x -> Map.get(input, x) end)

    [start | rest] = Utils.Graph.get_path(paths, goal)

    paths |> IO.inspect
    rest
    |> Enum.map(&Map.get(input, &1))
    |> IO.inspect
    |> Enum.sum()
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

  def weight_for_point(map, point), do: Map.get(map, point)
end
