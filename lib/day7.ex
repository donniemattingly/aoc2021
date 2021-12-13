defmodule Day7 do
  use Utils.DayBoilerplate, day: 7

  def sample_input do
    """
    16,1,2,0,4,2,7,1,2,14
    """
  end

  def triangle(n) do
    (n * (n + 1)) / 2
  end

  def get_fuel_consumed_for_pos(starting_positions, pos) do
    starting_positions
    |> Enum.map(& pos - &1)
    |> Enum.map(&Kernel.abs/1)
    |> Enum.sum
  end

  def get_fuel_consumed_for_pos_triangle(starting_positions, pos) do
    starting_positions
    |> Enum.map(&triangle(abs(pos - &1)))
    |> Enum.sum
  end

  def parse_input(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def solve1(input), do: solve(input, &get_fuel_consumed_for_pos/2)
  def solve2(input), do: solve(input, &get_fuel_consumed_for_pos_triangle/2)
  def solve(input, fuel_fn) do
    {min, max} = Enum.min_max(input)

    min..max
    |> Enum.map(fn pos -> {pos, fuel_fn.(input, pos)} end)
    |> Enum.min_by(fn {pos, amount} -> amount end)
  end
end