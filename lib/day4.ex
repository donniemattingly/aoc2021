defmodule Day4 do
  @moduledoc false

  def real_input do
    Utils.get_input(4, 1)
  end

  def sample_input do
    """
    7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

    22 13 17 11  0
    8  2 23  4 24
    21  9 14 16  7
    6 10  3 18  5
    1 12 20 15 19

    3 15  0  2 22
    9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
    2  0 12  3  7
    """
  end

  def sample_input2 do
    """
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
  def solve2(input), do: solve(input)

  def parse_and_solve1(input),
      do: parse_input1(input)
          |> solve1
  def parse_and_solve2(input),
      do: parse_input2(input)
          |> solve2

  def parse_input(input) do
    [num_str | boards] = input
                         |> String.split("\n\n")
    nums = num_str
           |> String.split(",")

    boards_map = boards
                 |> Enum.map(&parse_board/1)

    {nums, boards_map}
  end

  def parse_board(board_str) do
    board_str
    |> String.split("\n")
    |> Enum.map(&String.split(&1))
    |> Enum.filter(fn a -> Enum.count(a) > 0 end)
    |> Utils.list_of_lists_to_map_by_point
    |> Map.new(fn {key, val} -> {val, key} end)
  end

  def do_draw(drawn, [], boards, alive), do: drawn
  def do_draw(drawn, [next | rest], boards, alive) do
    winners = boards
              |> Enum.map(&is_winning_board(drawn, &1))
              |> Enum.filter(fn {won, board} -> won end)
              |> Enum.map(&elem(&1, 1))

    wins = winners
           |> Enum.map(&elem(&1, 1))
    not_winners = boards
                  |> Enum.filter(fn board -> !Enum.any?(wins, & &1 == board) end)

    case Enum.count(not_winners) do
      0 -> {drawn, hd(alive)}
      _ -> do_draw([next | drawn], rest, boards, not_winners)
    end
  end

  def calc_score(drawn, board) do
    board_values = board
                   |> Map.keys()
                   |> MapSet.new()

    drawn_values = drawn
                   |> MapSet.new()

    sum = MapSet.difference(board_values, drawn_values)
          |> Enum.map(&String.to_integer/1)
          |> Enum.sum

    last = drawn
           |> hd
           |> String.to_integer

    last * sum
  end

  def winning_combs do
    [
      [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}],
      [{0, 1}, {1, 1}, {2, 1}, {3, 1}, {4, 1}],
      [{0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}],
      [{0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3}],
      [{0, 4}, {1, 4}, {2, 4}, {3, 4}, {4, 4}],
      [{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}],
      [{1, 0}, {1, 1}, {1, 2}, {1, 3}, {1, 4}],
      [{2, 0}, {2, 1}, {2, 2}, {2, 3}, {2, 4}],
      [{3, 0}, {3, 1}, {3, 2}, {3, 3}, {3, 4}],
      [{4, 0}, {4, 1}, {4, 2}, {4, 3}, {4, 4}]
    ]
  end

  def is_winning_board(called_numbers, board) do
    points = called_numbers
             |> Enum.map(&Map.get(board, &1))
             |> MapSet.new

    winner = winning_combs
             |> Enum.map(fn combination -> Enum.all?(combination, &MapSet.member?(points, &1)) end)
             |> Enum.any?()

    {winner, board}
  end

  def solve({nums, boards}) do
    {drawn, board} = do_draw([], nums, boards, boards)
                     |> IO.inspect
    calc_score(drawn, board)
  end
end
