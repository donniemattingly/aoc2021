defmodule Day5 do
  use Utils.DayBoilerplate, day: 5

  def sample_input do
    """
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    String.split(line, " -> ")
    |> Enum.map(&parse_point/1)
  end

  def parse_point(point_string) do
    [a, b] = point_string
             |> String.split(",")
             |> Enum.map(&String.to_integer/1)

    {a, b}
  end

  def points_in_segment({ax, ay}, {bx, by}, _) when ay == by, do: ax..bx |> Enum.map(& {&1, ay})
  def points_in_segment({ax, ay}, {bx, by}, _) when ax == bx, do: ay..by |> Enum.map(& {ax, &1})
  def points_in_segment({ax, ay}, {bx, by}, diagonals) when diagonals == true, do: Enum.zip(ax..bx, ay..by)
  def points_in_segment({ax, ay}, {bx, by}, _), do: []

  def count_lines_with_overlap(input, diagonals) do
    input
    |> Enum.flat_map(fn [a, b] -> points_in_segment(a, b, diagonals) end)
    |> Enum.reduce(%{}, fn point, map -> Map.update(map, point, 1, & &1 + 1) end)
    |> Map.to_list
    |> Enum.filter(fn {_, hit_times} -> hit_times >= 2 end)
    |> Enum.count
  end

  def solve(input), do: count_lines_with_overlap(input, false)
  def solve2(input), do: count_lines_with_overlap(input, true)

end
