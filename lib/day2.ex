defmodule Day2 do
  @moduledoc false

  def real_input do
    Utils.get_input(2, 1)
  end

  def sample_input do
    """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """
  end

  def sample_input2 do
    """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """
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

  def parse_and_solve1(input),
      do: parse_input1(input)
          |> solve1
  def parse_and_solve2(input),
      do: parse_input2(input)
          |> solve2

  def parse_direction("forward"), do: :f
  def parse_direction("down"), do: :d
  def parse_direction("up"), do: :u

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [dir, num] -> {parse_direction(dir), String.to_integer(num)} end)
  end


  def solve2(input), do: calculate_position(input)
  def calculate_position(input) do
    do_calculate_position(input, 0, 0, 0);
  end

  def do_calculate_position([], _, depth, h_pos), do: depth * h_pos
  def do_calculate_position([move | moves], aim, depth, h_pos) do
    case move do
      {:u, amount} -> do_calculate_position(moves, aim - amount, depth, h_pos)
      {:d, amount} -> do_calculate_position(moves, aim + amount, depth, h_pos)
      {:f, amount} -> do_calculate_position(moves, aim, depth + aim * amount, h_pos + amount)
    end
  end

  def solve(input) do
    horizontal =
      input
      |> Enum.map(
           fn
             {:f, move} -> move
             _ -> 0
           end
         )
      |> Enum.sum

    vertical =
      input
      |> Enum.map(
           fn
             {:u, move} -> -1 * move
             {:d, move} -> move
             _ -> 0
           end
         )
      |> Enum.sum

    horizontal * vertical
  end
end
