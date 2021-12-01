defmodule Day1 do
  @moduledoc false

  def real_input do
    Utils.get_input(1, 1)
  end

  def sample_input do
    """
    199
    200
    208
    210
    200
    207
    240
    269
    260
    263
    """
  end

  def sample_input2 do
    sample_input()
  end

  def sample do
    sample_input()
    |> parse_input1
    |> solve1
  end

  def part1 do
    real_input1()
    |> parse_input1
    |> solve1
  end

  def sample2 do
    sample_input2()
    |> parse_input2
    |> solve2
  end

  def part2 do
    real_input2()
    |> parse_input2
    |> solve2
  end

  def real_input1, do: real_input()
  def real_input2, do: real_input()


  def parse_input1(input), do: parse_input(input)
  def parse_input2(input), do: parse_input(input)

  def solve1(input), do: solve(input)

  def parse_and_solve1(input), do: parse_input1(input) |> solve1
  def parse_and_solve2(input), do: parse_input2(input) |> solve2

  def parse_input(input) do
    input
    |> Utils.split_lines
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    depths = Enum.drop(input, 1)
    prev_depths = Enum.drop(input, -1)

    Enum.zip(depths, prev_depths)
    |> Enum.map(fn {depth, prev} -> depth > prev end)
    |> Enum.count(&(&1))
  end

  def solve2(input) do
    depths = Enum.drop(input, 1)
    prev_depths = Enum.drop(input, -1)

    first = Enum.drop(depths, -1)
    middle = Enum.drop(depths, 1)
    last = Enum.drop(prev_depths, -1)

    first
    |> Enum.zip(middle)
    |> Enum.zip(last)
    |> Enum.map(fn {{a, b}, c} -> a + b + c end)
    |> solve1
  end
end
