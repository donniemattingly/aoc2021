defmodule Day18 do
  import Logger
  use Utils.DayBoilerplate, day: 18

  def sample_input do
    """
    [[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]
    [2,9]
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_and_parse_lines(
         fn l ->
           l
           |> Code.eval_string()
           |> elem(0)
         end
       )
    |> Enum.map(&parse_snailfish_number/1)
  end

  def solve([h | t]) do
    t
    |> Enum.reduce(h, fn x, acc -> add(acc, x) end)
  end

  @doc"""
  [[1, 2], 3]

  at each node, generate an id
  that id becomes the key of the map
  nodes have
    left: value | key
    right: value | key
    parent: value | key

  this gets a bit tricky having the parent ref, we can assign child keys in the parent function
  """
  # [[1, 2], 3]
  def test do

  end

  def parse_index(node) do
    Map.update(node, :index, 0, &Convert.binary_to_integer/1)
  end

  def psn(num), do: parse_snailfish_number(num)
  def parse_snailfish_number(num) do
    do_parse_snailfish_number(num, Utils.random_string(30), nil, <<0 :: size(1)>>)
    |> Utils.List.flatten()
    |> Enum.map(fn a -> {a.id, parse_index(a)} end)
    |> Map.new
  end

  def do_parse_snailfish_number([a, b], key, parent, index) when is_number(a) and is_number(b) do
    %{id: key, parent: parent, left: a, right: b, index: index}
  end

  def do_parse_snailfish_number([a, b], key, parent_key, index) do
    l_id = Utils.random_string(30)
    r_id = Utils.random_string(30)

    [
      %{
        id: key,
        parent: parent_key,
        left: (if is_number(a), do: a, else: l_id),
        right: (if is_number(b), do: b, else: r_id),
        index: index
      },
      (if !is_number(a), do: do_parse_snailfish_number(a, l_id, key, <<index :: bitstring, 0 :: size(1)>>), else: []),
      (if !is_number(b), do: do_parse_snailfish_number(b, r_id, key, <<index :: bitstring, 1 :: size(1)>>), else: []),
    ]
  end

  def print(map, label \\ "") do
    start = map
            |> Map.values
            |> Enum.find(fn x -> x.parent == nil end)

    new = put_in(map[start.id][:highlighted], true)
    IO.puts("#{label} #{do_print(new, start.id)}")
  end

  def do_print(map, val) when is_number(val), do: val
  def do_print(map, node_id) do
    node = Map.get(map, node_id)
    str = "[#{do_print(map, node.left)}, #{do_print(map, node.right)}]"
    if node[:highlighted] != nil do
      IO.ANSI.format([:blue, str])
    else
      str
    end
  end

  def render(map), do: render_snailfish_number(map)
  def render_snailfish_number(map) do
    start = map
            |> Map.values
            |> Enum.find(fn x -> x.parent == nil end)

    do_render_snailfish_number(map, start.id)
  end

  def do_render_snailfish_number(map, value) when is_number(value), do: value
  def do_render_snailfish_number(map, node_id) do
    node = Map.get(map, node_id)
    [do_render_snailfish_number(map, node.left), do_render_snailfish_number(map, node.right)]
  end

  def get_depth(id, map, cur_depth \\ 0) do
    node = Map.get(map, id)
    case node.parent do
      nil -> cur_depth
      parent -> get_depth(parent, map, cur_depth + 1)
    end
  end

  #  defp dfs1(:leaf, _), do: []
  #  defp dfs1(%{value: val, left: :leaf, right: :leaf}, _), do: [val]
  #  defp dfs1(tree_node, order) do
  #    dfs(tree_node.left) ++ [tree_node.value] ++ dfs(tree_node.right)
  #  end

  def map_to_dfs_list(map) do
    start = map
            |> Map.values
            |> Enum.find(fn x -> x.parent == nil end)

    do_dfs(map, start.id, nil, nil)
  end

  def do_dfs(map, current_id, prev_id, side) when is_number(current_id), do: [{current_id, prev_id, side}]
  def do_dfs(map, current_id, prev_id, side) do
    node = Map.get(map, current_id)
    do_dfs(map, node.left, current_id, :left) ++ do_dfs(map, node.right, current_id, :right)
  end


  def add_to_first_regular_number_in_direction(map, id, direction, num) do
    node = Map.get(map, id)
    parent = Map.get(map, node.parent)

    cond do
      is_number(node[direction]) ->
        new_node = Map.put(node, direction, node[direction] + num)
        Map.put(map, id, new_node)
      parent == nil -> map
      parent ->
        add_to_first_regular_number_in_direction(map, node.parent, direction, num)
    end
  end

  def replace_exploded_node(map, parent, id) do
    new = Map.get(map, parent)
          |> Map.to_list
          |> Enum.map(
               fn
                 {k, ^id} -> {k, 0}
                 x -> x
               end
             )
          |> Map.new

    Map.put(map, parent, new)
  end

  def can_explode?(map) do
    map
    |> Enum.map(fn {k, v} -> {k, Day18.get_depth(k, map)} end)
    |> Enum.filter(fn {_, d} -> d >= 4 end)
    |> Enum.empty?
    |> Kernel.!
  end

  def get_exploding_pair(map) do
    ordered = map_to_dfs_list(map)

    depths = map
             |> Enum.map(fn {k, v} -> {k, Day18.get_depth(k, map)} end)

    depths
    |> Enum.map(fn {k, d} -> {Map.get(map, k), d} end)
    |> Enum.map(fn {node, d} -> {[node.left, node.right], d} end)
    |> inspect(charlists: :as_lists)
    |> Logger.info()

    potential = depths
                |> Enum.filter(fn {_, d} -> d >= 4 end)
                |> Enum.map(fn {k, _} -> {k, Map.get(map, k)} end)
                |> Map.new()

    Map.values(potential)
    |> Enum.map(fn node -> [node.left, node.right] end)
    |> IO.inspect(charlists: :as_lists, label: "potential")

    id_to_explode = ordered
                    |> Enum.map(&elem(&1, 1))
                    |> Enum.filter(fn id -> Map.has_key?(potential, id) end)
                    |> hd

    Map.get(potential, id_to_explode)
  end

  def explode(map) do
    node = get_exploding_pair(map)
    ordered = map_to_dfs_list(map)
              |> Enum.chunk_every(2, 1)
              |> Enum.filter(&Enum.count(&1) == 2)

    print(map, "tree: ")
    IO.inspect([node.left, node.right], label: "exploding", charlists: :as_lists)
    print(put_in(map[node.id][:highlighted], true), "explosion: ")

    right = case Enum.find(ordered, fn [{_, a, _}, {_, b, _}] -> a != b and a == node.id end) do
      nil ->
        nil
      x ->
        Enum.at(x, 1)
    end
    left = case Enum.find(ordered, fn [{_, a, _}, {_, b, _}] -> a != b and b == node.id end) do
      nil ->
        nil
      x ->
        Enum.at(x, 0)
    end

    map = if right != nil do
      {val, id, side} = right
      update_in(map[id][side], & &1 + node.right)
    else
      map
    end

    map = if left != nil do
      {val, id, side} = left
      update_in(map[id][side], & &1 + node.left)
    else
      map
    end

    map
    |> Map.delete(node.id)
    |> replace_exploded_node(node.parent, node.id)
  end

  def explode2(map) do
    node = get_exploding_pair(map)
    map
    |> add_to_first_regular_number_in_direction(node.parent, :left, node.left)
    |> add_to_first_regular_number_in_direction(node.parent, :right, node.right)
    |> Map.delete(node.id)
    |> replace_exploded_node(node.parent, node.id)
  end

  def can_split?(map) do
    get_splitting_pair(map, :left) ++ get_splitting_pair(map, :right)
    |> Enum.empty?
    |> Kernel.!
  end

  def get_splitting_pair(map) do
    get_splitting_pair(map, :left) ++ get_splitting_pair(map, :right)
    |> Enum.min_by(fn {node, _} -> node.index end)
  end

  def get_splitting_pair(map, direction) do
    map
    |> Map.values
    |> Enum.map(&{&1, direction})
    |> Enum.filter(fn {v, _} -> is_number(v[direction]) and v[direction] > 9 end)
  end

  def replace_splitting_number(map, {node, direction}) do
    num = node[direction]
    key = Utils.random_string(30)
    new_index = <<node.index :: 32, (if direction == :left, do: 0, else: 1) :: size(1)>>
                |> Convert.binary_to_integer()
    new_node = %{id: key, parent: node.id, left: floor(num / 2), right: ceil(num / 2), index: new_index}
    transformed_node = Map.put(node, direction, key)

    result = map
    |> Map.put(node.id, transformed_node)
    |> Map.put(key, new_node)

    IO.inspect([new_node.left, new_node.right], label: "inserting", charlists: :as_lists)
    print(put_in(result[key][:highlight], true), "splitting")

    result
  end

  def split(map) do
    replace_splitting_number(map, get_splitting_pair(map))
  end

  def reduce(map) do
    IO.puts("\nReduce")
    res = cond do
      can_explode?(map) ->
        IO.puts("Can Explode")
        map
        |> explode
        |> reduce
      can_split?(map) ->
        IO.puts("Can Split")
        map
        |> split
        |> reduce
      true -> map
    end

    inspect(
      res
      |> render_snailfish_number,
      charlists: :as_lists,
      label: "reduce"
    )
    |> Logger.info

    res
  end

  def add(a, b) do
    pa = render_snailfish_number(a)
    pb = render_snailfish_number(b)
    parsed = [pa, pb]
             |> parse_snailfish_number

    #    Logger.info(inspect(parsed, label: "parsed"))

    res = parsed
          |> reduce

    #    IO.inspect(
    #      res
    #      |> render_snailfish_number,
    #      charlists: :as_lists,
    #      label: "add"
    #    )

    #    IO.puts("\n\nNEW")
    Logger.info(inspect(pa, label: "  ", charlists: :as_lists))
    Logger.info(inspect(pb, label: "+ ", charlists: :as_lists))
    Logger.info(inspect(render_snailfish_number(res), label: "= ", charlists: :as_lists))
    res
  end
end
