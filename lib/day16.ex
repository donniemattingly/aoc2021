defmodule Day16 do
  use Utils.DayBoilerplate, day: 16

  def sample_input do
    """
    """
  end

  def parse_input(input) do
    input
  end

  def parse_version(<<t :: size(3), rest :: bitstring>>), do: {t, rest}
  def parse_id(<<t :: size(3), rest :: bitstring>>), do: {t, rest}

  def parse_packet(p = <<version :: size(3), 4 :: size(3), rest :: bitstring>>) do
    {value, rest} = parse_literal_chunk(rest, <<>>)
    packet_size = Convert.bitstring_size(p)
    rest_size = Convert.bitstring_size(rest)
    {[version: version, id: 4, size: packet_size - rest_size, value: value], rest}
  end

  def parse_literal_chunk(<<1 :: size(1), chunk :: size(4), rest :: bitstring>>, num) do
    parse_literal_chunk(rest, <<num :: bitstring, chunk :: size(4)>>)
  end

  def parse_literal_chunk(<<0 :: size(1), chunk :: size(4), rest :: bitstring>>, num) do
#    IO.inspect({chunk, rest, num}, label: "zero leading")
    {Convert.binary_to_integer(<<num :: bitstring, chunk :: size(4)>>), rest}
  end

  def parse_packet(p = <<v :: size(3), t :: size(3), 0 :: size(1), l :: size(15), rest :: bitstring>>) do
    packet_size = Convert.bitstring_size(p)
    rest_size = Convert.bitstring_size(rest)
    result = parse_fixed_len_packet(rest, [], l)
    IO.puts("fixed len: #{l}")
    IO.inspect(result, label: "packet")
    {[version: v, id: t, size: packet_size - rest_size, value: result], rest}
  end

  def parse_fixed_len_packet(packet, parsed, 0), do: {parsed, packet}
  def parse_fixed_len_packet(packet, parsed, remaining) do
    {result, rest} = parse_packet(packet)
    [version: version, id: _, size: size, value: value] = result
    parse_fixed_len_packet(rest, [result | parsed], remaining - size)
  end

  def parse_packet(p = <<v :: size(3), t :: size(3), 1 :: size(1), l :: size(11), rest :: bitstring>>) do
    packet_size = Convert.bitstring_size(p)
    rest_size = Convert.bitstring_size(rest)
    result = parse_fixed_count_packet(rest, [], l)
    IO.puts("fixed count: #{l}")
    IO.inspect(result, label: "packet")
    {[version: v, id: t, size: packet_size - rest_size, value: result], rest}
  end

  def parse_fixed_count_packet(packet, parsed, 0), do: {parsed, packet}
  def parse_fixed_count_packet(packet, parsed, remaining) do
    {result, rest} = parse_packet(packet)
    parse_fixed_count_packet(rest, [result | parsed], remaining - 1)
  end

  def solve(input) do
    input
    |> Base.decode16!()
    |> parse_packet()
  end


  def nested_packet do
    "8A004A801A8002F478"
    |> Day16.solve
  end

  def nested2 do
    solve("620080001611562C8802118E34")
  end

end
