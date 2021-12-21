defmodule Day21 do
  use Utils.DayBoilerplate, day: 21
  use Memoize

  def sample_input do
    """
    Player 1 starting position: 4
    Player 2 starting position: 8
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_and_parse_lines(
         fn l ->
           [a, b] = String.split(l, ":", trim: true)
                    |> Enum.map(&String.trim/1)
           String.to_integer(b)
         end
       )
  end

  def player_from_starting_position(pos) do
    %{pos: pos, score: 0}
  end

  def initial_game_from_starting_positions(positions) do
    positions
    |> Utils.List.zip_with_index()
    |> Enum.map(fn {pos, index} -> {index, player_from_starting_position(pos)} end)
    |> Map.new
  end

  def solve(input) do
    result = input
             |> initial_game_from_starting_positions
             |> run_game
             |> IO.inspect

    Enum.min([result[0].score, result[1].score]) * result.rolls
  end

  def solve2(input) do
    input
    |> initial_game_from_starting_positions
    |> run2
    |> IO.inspect
    |> Map.values()
    |> Enum.max()
  end

  def run_game(game) do
    do_run_game(
      0,
      game,
      1..100
      |> Enum.to_list,
      0
    )
  end


  def score(x) do
    case rem(x, 10) do
      0 -> 10
      y -> y
    end
  end

  def has_winner?(game) do
    Map.to_list(game)
    |> Enum.any?(fn {_, p} -> p.score >= 1000 end)
  end

  def has_winner2?(game) do
    Map.to_list(game)
    |> Enum.any?(fn {_, p} -> p.score >= 21 end)
  end

  @doc"""

  """
  def do_run_game(active, game, [a, b, c | rest], rolls) do
    new_pos = score(game[active].pos + a + b + c)
    new_score = game[active].score + new_pos
    IO.inspect([roll: [a, b, c], active: active, score: new_score, pos: new_pos], label: "roll", charlists: :as_lists)
    new_game = %{
      game |
      active => %{
        pos: new_pos,
        score: new_score
      }
    }

    cond do
      has_winner?(new_game) -> Map.put(new_game, :rolls, rolls + 3)
      true -> do_run_game(rem(active + 1, 2), new_game, rest, rolls + 3)
    end
  end

  @doc"""
  If we can't match on [a, b, c | rest] just add another 100
  """
  def do_run_game(active, scores, l, rolls) do
    IO.puts("\n ---- Die Reset ----")
    do_run_game(
      active,
      scores,
      l ++ (
        1..100
        |> Enum.to_list),
      rolls
    )
  end

  def run2(game) do
    do_run2(0, game, [])
  end

  @doc"""
  recursively create universes and hope memoization is the answer. we build a stack of rolls that does a score at 3
  this function returns a %{player1, player2} tuple which is the number of outcomes in which that player won
  """
  defmemo do_run2(active, game, [a, b, c]) do
    new_pos = score(game[active].pos + a + b + c)
    new_score = game[active].score + new_pos
    new_game = %{
      game |
      active => %{
        pos: new_pos,
        score: new_score
      }
    }

    cond do
      has_winner2?(new_game) -> %{active => 1, rem(active + 1, 2) => 0}
      true -> do_run2(rem(active + 1, 2), new_game, [])
    end
  end

  defmemo do_run2(active, game, roll) do
    1..3
    |> Enum.map(&do_run2(active, game, [&1 | roll]))
    |> Enum.reduce(%{0 => 0, 1 => 0}, fn x, acc -> %{0 => acc[0] + x[0], 1 => acc[1] + x[1]} end)
  end
end
