defmodule Utils do
  @moduledoc """
  Various Utility functions for solving advent of code problems.
  """

  @log true

  @doc ~S"""
  Reads a file located at `inputs/input-{day}-{part}.txt`


  ## Options

  - `:stream`
    if true will use `File.stream!/1` defaults to  `File.read!/1`

  - `:split`
    if true will split the input line by line


  ## Examples

      iex> Utils.get_input(0, 0)
      "Test File\nWith Lines"

      iex> Utils.get_input(0, 0, split: true)
      ["Test File", "With Lines"]

      iex> Utils.get_input(0, 0, stream: true) |> Stream.run
      :ok
  """
  def get_input(day, part, options \\ []) do
    read =
      case Keyword.get(options, :stream, false) do
        true -> &File.stream!/1
        false -> &File.read!/1
      end

    map =
      case Keyword.get(options, :split, false) do
        true -> fn x -> String.split(x, "\n", trim: true) end
        false -> fn x -> x end
      end

    "inputs/input-#{day}-#{part}.txt"
    |> read.()
    |> map.()
  end

  def single_value(input) do
    String.trim(input)
  end

  def split_lines(input) do
    input
    |> String.split("\n")
    |> Enum.filter(fn line -> !Enum.member?(["", "\n"], line) end)
    |> Enum.map(&String.trim/1)
  end

  def split_and_parse_lines(input, parser_fn) do
    input
    |> split_lines()
    |> Enum.map(fn x -> parser_fn.(x) end)
  end

  def split_each_char(input) do
    input
    |> String.split("")
    |> Enum.filter(fn line -> !Enum.member?(["", "\n"], line) end)
  end

  def clamp(number, minimum, maximum) do
    number
    |> max(minimum)
    |> min(maximum)
  end

  def at_least(number, minimum) do
    number
    |> max(minimum)
  end

  @doc """
  Run the function `fun` and returns the time in seconds elapsed
  while running it
  """
  def time(fun) do
    {elapsed, _} = :timer.tc(fun)
    elapsed / 1_000_000
  end

  def benchmark(fun, sample) do
    1..sample
    |> Enum.map(fn _ -> time(fun) end)
    |> Enum.sum()
    |> Kernel./(sample)
  end

  @doc """
  Inspects a value, but only if a random value generate is greater than
  `threshold`

  This is intended to be used with large streams of data that you
  want to investigate without printing every value.
  """
  def sample(value, threshold \\ 0.999) do
    case :rand.uniform() > threshold do
      true -> IO.inspect(value)
      _ -> value
    end
  end

  @doc """
  Generates the md5 hash of a value and encodes it as a lowercase base16 encoded string.

  ## Examples

      iex> Utils.md5("advent of code")
      "498fa12185ebe8a9231b9072da43c988"
  """
  def md5(value) do
    :crypto.hash(:md5, value)
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Swaps the element at `pos_a` in `list` with the element at `pos_b`

  ## Examples
      iex> Utils.swap([1, 2, 3], 0, 1)
      [2, 1, 3]

  """
  def swap(list, pos_a, pos_a), do: list

  def swap(list, pos_a, pos_b) when pos_a < pos_b do
    {initial, rest} = Enum.split(list, pos_a)
    {between, tail} = Enum.split(rest, pos_b - pos_a)
    a = hd(between)
    b = hd(tail)
    initial ++ [b] ++ tl(between) ++ [a] ++ tl(tail)
  end

  def swap(list, pos_a, pos_b) when pos_b < pos_a, do: swap(list, pos_b, pos_a)

  @doc """
  Generates all the permutations for the input `list`

  ## Examples
      iex> Utils.permutations([1, 2, 3])
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  """
  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def log_inspect(value, description, opts \\ []) when @log do
    IO.puts(description <> ": ")
    IO.inspect(value, opts)
  end

  def combinations(list, num)
  def combinations(_list, 0), do: [[]]
  def combinations(list = [], _num), do: list

  def combinations([head | tail], num) do
    Enum.map(combinations(tail, num - 1), &[head | &1]) ++
      combinations(tail, num)
  end

  def log_inspect(value), do: value

  def flatten_map(map) when is_map(map) do
    map
    |> Map.to_list()
    |> do_flatten([])
    |> IO.inspect()
    |> Map.new()
  end

  defp do_flatten([], acc), do: acc

  defp do_flatten([{_k, v} | rest], acc) when is_map(v) do
    v = Map.to_list(v)
    flattened_subtree = do_flatten(v, acc)
    do_flatten(flattened_subtree ++ rest, acc)
  end

  defp do_flatten([kv | rest], acc) do
    do_flatten(rest, [kv | acc])
  end

  def nested_tuple_to_list(list) when is_list(list) do
    Enum.map(list, &nested_tuple_to_list/1)
  end

  def nested_tuple_to_list(tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&nested_tuple_to_list/1)
  end

  def nested_tuple_to_list(x), do: x

  def color_for_digit(digit) do
    import IO.ANSI

    colors = [
      "#e6194b",
      "#3cb44b",
      "#ffe119",
      "#4363d8",
      "#f58231",
      "#911eb4",
      "#46f0f0",
      "#f032e6",
      "#bcf60c",
      "#fabebe",
      "#008080",
      "#e6beff",
      "#9a6324",
      "#fffac8",
      "#800000",
      "#aaffc3",
      "#808000",
      "#ffd8b1",
      "#000075",
      "#808080",
      "#ffffff",
      "#000000"
    ]

    %{red: r, green: g, blue: b} =
      Enum.at(
        colors,
        digit
        |> String.to_integer()
      )
      |> String.upcase()
      |> ColorUtils.hex_to_rgb()

    color_background(floor(r / 50), floor(g / 50), floor(b / 50))
  end

  def rgb_color_background(r, g, b) do
    import IO.ANSI

    color_background(floor(r / 50), floor(g / 50), floor(b / 50))
  end

  def colorize_digit(digit) do
    import IO.ANSI

    digit <>
      (digit
       |> color_for_digit)
  end

  def colorize(str, color) do
    import IO.ANSI

    colors = %{
      red: rgb_color_background(100, 0, 0),
      green: rgb_color_background(0, 100, 0),
      blue: rgb_color_background(0, 0, 100)
    }

    colors[color] <> str <> IO.ANSI.default_background()
  end

  def colorize_digits(digits) do
    result =
      String.split(digits, "", trim: true)
      |> Enum.map(&colorize_digit/1)
      |> Enum.join()

    result <> IO.ANSI.default_background()
  end

  def list_of_lists_to_map_by_point(list_of_lists) do
    list_of_lists
    |> Stream.with_index()
    |> Stream.flat_map(&row_to_point_value_pair/1)
    |> Enum.into(%{})
  end

  def row_to_point_value_pair({row, row_number}) do
    row
    |> Stream.with_index()
    |> Stream.map(fn {value, x} -> {{x, row_number}, value} end)
  end

  @doc """
  Map.put but each put will perform and aggregation function which
  keeps in state in the map. Think keeping a running total of the
  largest value so you don't have to scan the entire map

  agg_fn takes the map and the value and produces a new map
  """
  def put_with_aggreation(agg_fn, map, key, value) do
    agg_fn.(map, value)
    |> Map.put(key, value)
  end

end
