defmodule Day8 do
  @moduledoc """
  8:
  aaaa
  b    c
  b    c
  dddd
  e    f
  e    f
  gggg
  """
  use Utils.DayBoilerplate, day: 8

  def sample_input do
    """
        be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
        edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
        fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
        fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
        aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
        fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
        dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
        bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
        egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
        gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_and_parse_lines(
         fn line ->
           String.split(line, " | ")
           |> Enum.map(&String.split/1)
         end
       )
  end

  def solve(input) do
    input
    |> Enum.map(fn [a, b | _] -> b end)
    |> Enum.map(&Enum.count(&1, fn l -> String.length(l) in [2, 3, 4, 7] end))
    |> Enum.sum
  end

  @doc"""
  1 -> cf
  4 -> bd
  7 -> a
  """

  def segments_for_number do
    ["abcefg", "cf", "acdeg", "acdfg", "bcdf", "abdfg", "abdefg", "acf", "abcdefg", "abcdfg"]
    |> Enum.map(&Utils.split_each_char/1)
    |> Enum.map(&MapSet.new/1)
    |> Stream.with_index()
    |> Stream.map(fn {set, index} -> {index, set} end)
    |> Map.new
  end

  def known_segments_by_length do
    %{2 => 1, 4 => 4, 3 => 7, 7 => 8}
  end

  def numbers_with_segment do
    segments_for_number
    |> Map.to_list
    |> Enum.flat_map(fn {number, segments} -> Enum.map(segments, &{number, &1}) end)
    |> Enum.reduce(%{}, fn {number, segment}, map -> Map.update(map, segment, [number], &[number | &1]) end)
  end

  def chars_different(a, b) do
    MapSet.new(a)
    |> MapSet.difference(MapSet.new(b))
    |> MapSet.size
  end

  def derive_segment_mapping(patterns) do
    by_chars = patterns
               |> Enum.map(&Utils.split_each_char/1)
    pos = by_chars
          |> get_known_segments

    one = Enum.find(by_chars, fn p -> Enum.count(p) == 2 end)
    four = Enum.find(by_chars, fn p -> Enum.count(p) == 4 end)
    eight = Enum.find(by_chars, fn p -> Enum.count(p) == 7 end)
    seven = Enum.find(by_chars, fn p -> Enum.count(p) == 3 end)

    six_segs = by_chars
               |> Enum.filter(fn it -> Enum.count(it) == 6 end)

    six = six_segs
          |> Enum.find(fn p -> chars_different(p, one) == 5 end)
    zero = MapSet.difference(MapSet.new(six_segs), MapSet.new([six]))
           |> MapSet.to_list
           |> Enum.find(fn p -> chars_different(p, four) == 3 end)
    nine = MapSet.difference(MapSet.new(six_segs), MapSet.new([six, zero]))
           |> MapSet.to_list
           |> hd

    five_segs = by_chars
                |> Enum.filter(fn it -> Enum.count(it) == 5 end)

    three = five_segs
            |> Enum.find(fn p -> chars_different(p, one) == 3 end)

    five = MapSet.difference(MapSet.new(five_segs), MapSet.new([three]))
           |> MapSet.to_list
           |> Enum.find(fn p -> chars_different(p, four) == 2 end)

    two = MapSet.difference(MapSet.new(five_segs), MapSet.new([three, five]))
          |> MapSet.to_list
          |> hd

    [zero, one, two, three, four, five, six, seven, eight, nine]
    |> Enum.map(&Enum.join/1)
    |> Stream.with_index()
    |> Stream.map(fn {set, index} -> {"#{index}", set} end)
    |> Map.new
  end

  def impossible_segments(number) do
    MapSet.difference(Map.get(segments_for_number(), 8), Map.get(segments_for_number(), number))
  end

  def possible_segment_mappings(pattern) do
    len = Enum.count(pattern)
    case Map.get(known_segments_by_length(), len) do
      nil ->
        pattern
        |> Enum.map(fn char -> {char, impossible_segments(8)} end)
      x ->
        pattern
        |> Enum.map(fn char -> {char, impossible_segments(x)} end)
    end
  end

  def get_known_segments(patterns) do
    patterns
    |> Enum.flat_map(&possible_segment_mappings/1)
    |> Enum.reduce(%{}, fn {char, segments}, map -> Map.update(map, char, segments, &MapSet.union(segments, &1)) end)
  end

  def sorted_str(str) do
    str
    |> Utils.split_each_char
    |> Enum.sort
    |> Enum.join
  end

  def solve_line([patterns, display]) do
    mappings = derive_segment_mapping(patterns)
               |> Map.to_list()
               |> IO.inspect
               |> Enum.map(fn {a, b} -> {sorted_str(b), a} end)
               |> IO.inspect
               |> Map.new

    display
    |> Enum.map(&sorted_str/1)
    |> Enum.map(fn char -> Map.get(mappings, char) end)
    |> Enum.join
  end

  def solve2(input) do
    input
    |> Enum.map(&solve_line/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end
end