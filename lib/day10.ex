defmodule Day10 do
  use Utils.DayBoilerplate, day: 10

  def sample_input do
    """
    [({(<(())[]>[[{[]{<()<>>
    [(()[<>])]({[<{<<[]>>(
    {([(<{}[<>[]}>{[]{[(<()>
    (((({<>}<{<{<>}{[]{[]{}
    [[<[([]))<([[{}[[()]]]
    [{[{({}]{}}([{[{{{}}([]
    {<[[]]>}<{[{[{[]{()[[[]
    [<(<(<(<{}))><([]([]()
    <{([([[(<>()){}]>(<<{{
    <{([{{}}[<[[[<>{}]]]>[]]
    """
  end

  @char_direction %{
    "(" => :open,
    ")" => :close,
    "[" => :open,
    "]" => :close,
    "{" => :open,
    "}" => :close,
    "<" => :open,
    ">" => :close,
  }

  @closers %{
    "(" => ")",
    "[" => "]",
    "<" => ">",
    "{" => "}",
  }

  def parse_input(input) do
    input
    |> Utils.split_and_parse_lines(&Utils.split_each_char/1)
  end

  def open_close_count(line) do
    open = Enum.count(
      line,
      fn char ->
        Map.get(@char_direction, char)
        |> IO.inspect == :open
      end
    )
    close = Enum.count(line, fn char -> Map.get(@char_direction, char) == :close end)

    {open, close}
  end

  def find_corrupted_chunk([h | t]), do: do_find_corrupted_chunk(t, [h])
  def do_find_corrupted_chunk([], []), do: :valid
  def do_find_corrupted_chunk([], stack), do: :incomplete
  def do_find_corrupted_chunk(line, []), do: :incomplete
  def do_find_corrupted_chunk(line = [line_head | line_rest], stack = [stack_head | stack_rest]) do
    dir = Map.get(@char_direction, line_head)
    closer = Map.get(@closers, stack_head)

    cond do
      dir === :open -> do_find_corrupted_chunk(line_rest, [line_head | stack])
      line_head == closer -> do_find_corrupted_chunk(line_rest, stack_rest)
      line_head != closer -> line_head
    end
  end

  def get_completion_pattern([h | t]), do: do_get_completion_pattern(t, [h], [])
#  def do_get_completion_pattern([], [], pattern), do: pattern
  def do_get_completion_pattern([], stack, pattern) do
    stack
    |> Enum.map(&Map.get(@closers, &1))
  end
  def do_get_completion_pattern([h | t], [], pattern), do: do_get_completion_pattern(t, [h], [])
  def do_get_completion_pattern(line = [line_head | line_rest], stack = [stack_head | stack_rest], pattern) do
    {line |> Enum.join, stack |> Enum.join,pattern |> Enum.join} |> IO.inspect
    dir = Map.get(@char_direction, line_head)
    closer = Map.get(@closers, stack_head)

    cond do
      dir === :open -> do_get_completion_pattern(line_rest, [line_head | stack], pattern)
      line_head == closer -> do_get_completion_pattern(line_rest, stack_rest, pattern)
      line_head != closer -> do_get_completion_pattern(line_rest, stack_rest, [closer | pattern])
    end
  end

  @values %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
  }

  def score(final_chars) do
    final_chars
    |> Enum.map(&Map.get(@values, &1, 0))
    |> Enum.sum()
  end

  def solve(input) do
    input
    |> Enum.map(&find_corrupted_chunk/1)
    |> score
  end

  @twoscores %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
  }

  def calc_two_score(pattern) do
    pattern
    |> Enum.map(&Map.get(@twoscores, &1))
    |> Enum.reduce(0, fn x, acc -> (5 * acc) + x end)
  end

  def solve2(input) do
    scores = incomplete_lines = input
    |> Enum.map(&find_corrupted_chunk/1)
    |> Enum.zip(input)
    |> Enum.filter(fn {char, _} -> char == :incomplete end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&get_completion_pattern/1)
    |> Enum.map(&calc_two_score/1)
    |> Enum.sort()

    middle_index = scores |> length() |> div(2)
    Enum.at(scores, middle_index)
  end
end
