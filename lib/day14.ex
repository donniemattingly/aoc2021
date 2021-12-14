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

  def solve({template, rules}) do
    IO.inspect(rules)
    ltemplate = String.to_charlist(template)
    {{a, na}, {b, nb}} = 1..40
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
end
