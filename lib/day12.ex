#defmodule Day12 do
#  use Utils.DayBoilerplate, day: 12
#
#  def sample_input do
#    """
#    fs-end
#    he-DX
#    fs-he
#    start-DX
#    pj-DX
#    end-zg
#    zg-sl
#    zg-pj
#    pj-he
#    RW-he
#    fs-DX
#    pj-RW
#    zg-RW
#    start-pj
#    he-WI
#    zg-he
#    pj-fs
#    start-RW
#    """
#  end
#
#  def parse_input(input) do
#    input
#    |> Utils.split_and_parse_lines(&parse_line/1)
#  end
#
#  def parse_line(input) do
#    input
#    |> String.split("-")
#  end
#
#  def generate_graph(edges) do
#    edges
#    |> Enum.reduce(
#         %{},
#         fn [a, b], acc ->
#           acc
#           |> Map.update(a, [b], fn x -> [b | x] end)
#           |> Map.update(b, [a], fn x -> [a | x] end)
#         end
#       )
#  end
#
#  def find_paths(graph, "end", path),
#      do: ["end" | path]
#          |> Enum.reverse
#          |> Enum.join(",")
#  def find_paths(graph, node, path) do
#    Map.get(graph, node, [])
#    |> Enum.filter(fn p -> p == String.upcase(p) or p not in path end)
#    |> Enum.map(&find_paths(graph, &1, [node | path]))
#  end
#
#  def find_paths2(graph, "end", path),
#      do: ["end" | path]
#          |> Enum.reverse
#          |> Enum.join(",")
#  def find_paths2(graph, node, path) do
#    Map.get(graph, node, [])
#    |> Enum.filter(&p2_filter(&1, path))
#    |> Enum.map(&find_paths2(graph, &1, [node | path]))
#  end
#
#  def p1_filter(node) do
#    String.upcase(node) or node not in path
#  end
#  def p2_filter(node, path) do
#    cond do
#      node == String.upcase(node) -> true
#      node === "start" -> false
#      node not in path -> true
#      node in path and has_two_small_caves(path) -> false
#      true -> true
#    end
#  end
#
#  def get_two_small_caves(path) do
#    path
#    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, & &1 + 1) end)
#    |> Map.to_list
#    |> Enum.filter(fn {_, c} -> c > 1 end)
#    |> Enum.filter(fn {x, _} -> x != String.upcase(x) end)
#  end
#
#  def has_two_small_caves(path) do
#    get_two_small_caves(path)
#    |> Enum.count > 0
#  end
#
#  def has_one_of_this_already(path, node) do
#    node in path
#  end
#
#
#  def solve(input) do
#    input
#    |> generate_graph
#    |> find_paths("start", [])
#    |> Utils.List.flatten
#    |> Enum.count
#  end
#
#  def solve2(input) do
#    input
#    |> generate_graph
#    |> find_paths2("start", [])
#    |> Utils.List.flatten
#    |> Enum.sort()
#    |> Enum.map(&String.split(&1, ","))
#    |> Enum.map(&Day12.get_two_small_caves/1)
#    |> Enum.filter(fn x -> Enum.count(x) < 2 end)
#    |> Enum.count
#  end
#end
