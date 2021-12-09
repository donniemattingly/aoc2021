defmodule Day9 do
  use Utils.DayBoilerplate, day: 9

  def sample_input do
    """
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines
    |> Enum.map(
         fn line ->
           line
           |> Utils.split_each_char
           |> Enum.map(&String.to_integer/1) end
       )
    |> Utils.list_of_lists_to_map_by_point()
  end

  def get_neighbors({x, y}) do
    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
  end

  def is_lower_than_neighbors(map, point) do
    val = Map.get(map, point, 0)
    neighbors = get_neighbors(point)
                |> Enum.map(fn n -> Map.get(map, n) end)

    Enum.all?(neighbors, fn n -> n > val end)
  end

  def get_basin(map, low_point) do
    basin = MapSet.new([low_point])
    |> grow_basin(map)
  end

  def is_higher?(map, p1, p2) do
    v1 = Map.get(map, p1)
    v2 = Map.get(map, p2)
    case v2 do
      nil -> false # out of bounds
      9 -> false # not in basins
      v2 -> v2 > v1
    end
  end

  def grow_basin(basin, map) do
    higher_neighbors = basin
    |> MapSet.to_list
    |> Enum.flat_map(fn point -> get_neighbors(point) |> Enum.map(& {point, &1}) end)
    |> Enum.filter(fn {point, neighbor} -> is_higher?(map, point, neighbor) end)
    |> Enum.map(&elem(&1, 1))

    new_basin = MapSet.union(basin, MapSet.new(higher_neighbors))
    growth = MapSet.difference(new_basin, basin) |> MapSet.size

    case growth do
      0 -> new_basin
      x -> grow_basin(new_basin, map)
    end
  end

  def get_low_points(input) do
    input
    |> Map.keys
    |> Enum.filter(fn point -> Day9.is_lower_than_neighbors(input, point) end)
  end

  def solve(input) do
    input
    |> get_low_points
    |> Enum.map(&Map.get(input, &1))
    |> Enum.map(& &1 + 1)
    |> Enum.sum
  end

  def solve2(input) do
    get_low_points(input)
    |> Enum.map(&get_basin(input, &1))
    |> Enum.map(fn set -> MapSet.size(set) end)
    |> Enum.sort_by(& &1, :desc)
    |> Enum.take(3)
    |> Enum.reduce(1, & &1 * &2)
  end
end
