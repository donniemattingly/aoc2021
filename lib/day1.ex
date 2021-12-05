defmodule Day1 do
  use Utils.DayBoilerplate, day: 1

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

  def parse_input(input) do
    input
    |> Utils.split_lines
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    input
    |> Enum.chunk_every(2, 1)
    |> Enum.filter(&match?([a, b], &1))
    |> Enum.count(fn [a, b] -> b > a end)
  end

  def solve2(input) do
    input
    |> Enum.chunk_every(3, 1)
    |> Enum.drop(-1)
    |> Enum.map(&Enum.sum/1)
    |> solve
  end
end
