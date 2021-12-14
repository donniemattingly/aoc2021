defmodule Day13 do
  use Utils.DayBoilerplate, day: 13

  def sample_input do
    """
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5
    """
  end

  def parse_input(input) do
    [points_str, folds_str] = String.split(input, "\n\n")

    points = parse_points(points_str)
    folds = parse_folds(folds_str)

    {points, folds}
  end

  def parse_points(input) do
    input
    |> Utils.split_and_parse_lines(
         fn x ->
           [a, b] = x
                    |> String.split(",")
                    |> Enum.map(&String.to_integer/1)
           {a, b}
         end
       )
  end

  def parse_folds(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(fn x -> [_, val] = String.split(x, "fold along "); val end)
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(fn [dir, val] -> {String.to_atom(dir), String.to_integer(val)} end)
  end

  def solve(input) do
    apply_folds(input, true)
    |> Matrex.to_list_of_lists()
    |> Utils.List.flatten()
    |> Enum.count(& &1 > 0)
  end

  def normalize(matrix) do
    Matrex.apply(matrix, fn x -> if x > 0, do: 1, else: 0 end)
  end

  def solve2(input) do
    apply_folds(input)
    |> normalize
    |> display
  end

  def display(matrix) do
    matrix
    |> Matrex.to_list_of_lists()
    |> Enum.map(fn line -> Enum.map(line, fn x -> if x > 0, do: "#", else: "." end) |> Enum.join("") end)
    |> Enum.join("\n")
    |> IO.puts

    IO.puts("\n\n")
    matrix
  end

  def create_matrix({points, folds}) do
    point_set = MapSet.new(points)
    max_x = points
            |> Enum.map(&elem(&1, 0))
            |> Enum.max
    max_y = points
            |> Enum.map(&elem(&1, 1))
            |> Enum.max
    Matrex.new(max_x+2, max_y+1, fn x, y -> if MapSet.member?(point_set, {x - 1, y - 1}), do: 1, else: 0 end)
    |> Matrex.transpose
  end

  def apply_folds(input = {_, folds}, only_one \\ false) do
    matrix = create_matrix(input)
    folds_to_run = if only_one, do: [hd(folds)], else: folds

    folds_to_run
    |> Enum.reduce(matrix, fn {dir, val}, matrix -> fold(matrix, dir, val) end)
  end


  def fold(matrix, :x, _col) do
    IO.puts(":x")
    {x, y} = Matrex.size(matrix)
    col = div(y, 2)
    rem = rem(y, 2)
    {col, _col, rem} |> IO.inspect
    a = Matrex.submatrix(matrix, 1..x, 1..col)
    b = Matrex.submatrix(matrix, 1..x, col + 1 + rem..y)
        |> Utils.Matrix.horizontal_reflection()
    Matrex.add(a, b)
  end

  def fold(matrix, :y, _row) do
    IO.puts(":y")
    {x, y} = Matrex.size(matrix)
    row = div(x, 2)
    rem = rem(x, 2)
    {row, _row, rem} |> IO.inspect
    a = Matrex.submatrix(matrix, 1..row, 1..y)
    b = Matrex.submatrix(matrix, row + 1 + rem..x, 1..y)
        |> Utils.Matrix.vertical_reflection()

    Matrex.add(a, b)
  end
end
