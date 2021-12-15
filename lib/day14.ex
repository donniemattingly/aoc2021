defmodule Day14 do
  use Utils.DayBoilerplate, day: 14

  def sample_input do
    """
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
    """
  end

  def parse_input(input) do
    [template, rules_str] = String.split(input, "\n\n")
    rules = rules_str
            |> Utils.split_and_parse_lines(fn x -> String.split(x, " -> ") end)
            |> Enum.map(fn [a, b] -> {String.to_charlist(a), String.to_charlist(b)} end)
            |> Map.new()

    {template, rules}
  end

  def get_replacer([pair, insert]) do
    [a, b] = String.to_charlist(pair)
    {
      pair,
      [a, insert, b]
      |> Enum.join("")
    }
  end

  def do_inserts(template, rules) do
    Enum.count(template)
    |> IO.inspect
    {l, str} = template
               |> Enum.reduce(
                    {"", []},
                    fn char, {last, string} ->
                      new_str = [last | string]
                      insert = Map.get(rules, [last, char], '')
                      {char, [insert | new_str]}
                    end
                  )

    [l | str]
    |> Enum.reverse
    |> Enum.filter(fn x -> x !== "" end)
  end

  def do_inserts_stream(template, rules) do
    template
    |> Stream.chunk_every(2, 1)
    |> Stream.map(
         fn
           chunk = [a, b] ->
             [a, Map.get(rules, chunk, ""), b]
           l -> l
         end
       )
    |> Stream.map(
         fn
           [a, b, c] -> [a, b]
           b -> b
         end
       )
    |> Enum.to_list
    |> Utils.List.flatten()
  end

  def char_counts(list) do
    list
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, & &1 + 1) end)
  end

  def iter(pairs, pair_rules) do
    pairs
    |> Map.to_list
    |> Enum.flat_map(
         fn
           {pair, count} ->
             Map.get(pair_rules, pair, [pair])
             |> Enum.map(&{&1, count})
         end
       )
    |> Enum.reduce(%{}, fn {p, c}, acc -> Map.update(acc, p, c, & &1 + c) end)
  end

  def to_pair_rules(rules) do
    rules
    |> Map.to_list
    |> Enum.map(fn {[k1, k2], [v]} -> {[k1, k2], [[k1, v], [v, k2]]} end)
    |> Map.new
  end

  def template_to_initial_pairs(template) do
    template
    |> String.to_charlist
    |> Enum.chunk_every(2, 1)
    |> Enum.filter(&Enum.count(&1) == 2)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, & &1 + 1) end)
  end

  def solve({template, rules}) do
    ltemplate = String.to_charlist(template)
    {{a, na}, {b, nb}} = 1..10
                         |> Enum.reduce(
                              ltemplate,
                              fn x, acc ->
                                IO.puts(x)
                                do_inserts_stream(acc, rules)
                                |> Enum.to_list
                              end
                            )
                         |> char_counts
                         |> Map.to_list
                         |> Enum.min_max_by(fn {_, x} -> x end)

    nb - na
  end

  def solve2({template, rules}) do
    initial_counts = template_to_initial_pairs(template)
    pair_rules = to_pair_rules(rules)

    result = 1..40
             |> Enum.reduce(
                  {initial_counts, []},
                  fn i, {acc, agg} ->
                    if rem(i, 10_000) == 0 do
                      IO.puts(i)
                    end
                    res = iter(acc, pair_rules)
                    {res, [res | agg]}
                  end
                )
             |> IO.inspect
    #             |> Enum.flat_map(fn {[a, b], count} -> [{[a], count}, {[b], count}] end)
    #             |> Enum.reduce(%{}, fn {char, count}, acc -> Map.update(acc, char, count, & &1 + count) end)
    #             |> Map.to_list
    #             |> hd
    #             |> elem(1)
    #             |> IO.inspect
  end
end
