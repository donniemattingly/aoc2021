defmodule Day16 do
  use Utils.DayBoilerplate, day: 16

  def sample_input do
    """
    """
  end

  def parse_input(input) do
    input
  end

  def parse_packet(p = <<version :: size(3), 4 :: size(3), rest :: bitstring>>) do
    {value, remaining} = parse_literal_chunk(rest, <<>>)
    packet_size = Convert.bitstring_size(p)
    rest_size = Convert.bitstring_size(rest)
    {[version: version, id: 4, size: packet_size - rest_size, value: value], remaining}
  end

  def parse_literal_chunk(<<1 :: size(1), chunk :: size(4), rest :: bitstring>>, num) do
    parse_literal_chunk(rest, <<num :: bitstring, chunk :: size(4)>>)
  end

  def parse_literal_chunk(<<0 :: size(1), chunk :: size(4), rest :: bitstring>>, num) do
    {Convert.binary_to_integer(<<num :: bitstring, chunk :: size(4)>>), rest}
  end

  def parse_packet(p = <<v :: size(3), t :: size(3), 0 :: size(1), l :: size(15), rest :: bitstring>>) do
    packet_size = Convert.bitstring_size(p)
    rest_size = Convert.bitstring_size(rest)
    {result, remaining} = parse_fixed_len_packet(rest, [], l)
    if t == 7, do: IO.inspect([v: v, t: t, l: l, count: Enum.count(result)])
    {[version: v, id: t, size: Convert.bitstring_size(p) - rest_size, value: result], remaining}
  end

  def parse_fixed_len_packet(packet, parsed, remaining) when remaining <= 0,
      do: {
        parsed
        |> Enum.reverse,
        packet
      }
  def parse_fixed_len_packet(packet, parsed, remaining) do
    case parse_packet(packet) do
      {result = [version: version, id: _, size: size, value: value], rest} ->
        parse_fixed_len_packet(rest, [result | parsed], remaining - size)
      x -> {parsed, packet}
    end
  end

  def parse_packet(p = <<v :: size(3), t :: size(3), 1 :: size(1), l :: size(11), rest :: bitstring>>) do
    packet_size = Convert.bitstring_size(p)
    rest_size = Convert.bitstring_size(rest)
    {result, remaining} = parse_fixed_count_packet(rest, [], l)
    if t == 7, do: IO.inspect([v: v, t: t, l: l, count: Enum.count(result)])
    {[version: v, id: t, size: packet_size - rest_size, value: result], remaining}
  end

  def parse_fixed_count_packet(packet, parsed, 0),
      do: {
        parsed
        |> Enum.reverse,
        packet
      }
  def parse_fixed_count_packet(packet, parsed, remaining) do
    case parse_packet(packet) do
      {result, rest} -> parse_fixed_count_packet(rest, [result | parsed], remaining - 1)
      _ -> {parsed, packet}
    end
  end

  def parse_packet(<<x :: bitstring>>), do: nil

  def sum_version(node) do
    value = Keyword.get(node, :value)
    cond do
      is_list(value) ->
        Keyword.get(node, :version) + (
          Enum.map(value, &sum_version/1)
          |> Enum.sum)
      is_number(value) ->
        Keyword.get(node, :version)
    end
  end


  def map_eval(value, fun \\ & &1),
      do: Enum.map(value, &eval_packet/1)
          |> fun.()
  def eval_packet([version: v, id: 0, size: size, value: value]),
      do: map_eval(value, &Enum.sum/1)
  def eval_packet([version: v, id: 1, size: size, value: value]),
      do: map_eval(value)
          |> Enum.reduce(1, &Kernel.*/2)
  def eval_packet([version: v, id: 2, size: size, value: value]),
      do: map_eval(value, &Enum.min/1)
  def eval_packet([version: v, id: 3, size: size, value: value]),
      do: map_eval(value, &Enum.max/1)
  def eval_packet([version: v, id: 4, size: size, value: value]), do: value
  def eval_packet([version: v, id: 5, size: size, value: value]) do
    [a, b | rest] = map_eval(value)
                    |> IO.inspect
    if a > b, do: 1, else: 0
  end
  def eval_packet([version: v, id: 6, size: size, value: value]) do
    [a, b | rest] = map_eval(value)
                    |> IO.inspect
    if a < b, do: 1, else: 0
  end
  def eval_packet(p = [version: v, id: 7, size: size, value: value]) do
    IO.inspect({:equal, p})
    [a, b | rest] = map_eval(value)
    if a == b, do: 1, else: 0
  end

  def solve(input) do
    {ast, padding} = input
                     |> Base.decode16!()
                     |> parse_packet()

    sum_version(ast)
  end

  def solve2(input) do
    {ast, padding} = input
                     |> Base.decode16!()
                     |> parse_packet()
    #
    #    IO.inspect(ast, syntax_colors: Utils.inspect_colors())
    #    eval_packet(ast)
    ast
  end

  def tests do
    true = solve("8A004A801A8002F478") == 16
    true = solve("620080001611562C8802118E34") == 12
    true = solve("C0015000016115A2E0802F182340") == 23
    true = solve("A0016C880162017C3686B18A3D4780") == 31
  end

end
