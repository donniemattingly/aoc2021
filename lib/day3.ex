defmodule Day3 do
  use Utils.DayBoilerplate, day: 3

  def sample_input do
    """
    00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010
    """
  end

  def transpose([[] | _]), do: []
  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&Utils.split_each_char/1)
  end

  def calc_row(row) do
    row
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end

  def solve(input) do
    size = Enum.count(input);

    partial = input
              |> transpose
              |> Enum.map(&calc_row/1)
              |> Enum.map(fn a -> a > size / 2 end)

    gamma = partial
            |> Enum.map(
                 fn
                   true -> 1
                   false -> 0
                 end
               )
            |> Enum.join()
            |> Integer.parse(2)
            |> elem(0)


    episilon = partial
               |> Enum.map(
                    fn
                      true -> 0
                      false -> 1
                    end
                  )
               |> Enum.join()
               |> Integer.parse(2)
               |> elem(0)

    gamma * episilon
  end

  def ox_val(values) do
    do_ox_val(values, 0)
  end

  def do_ox_val([val | []], _),
      do: val
          |> Enum.join()
          |> Integer.parse(2)
          |> elem(0)
  def do_ox_val(values, pos) do
    bit = most_common_bit_at_pos(values, pos)
    new_values = values
                 |> Enum.filter(
                      fn val ->
                        Enum.at(val, pos) == bit
                      end
                    )
    do_ox_val(new_values, pos + 1)
  end

  def co2_val(values) do
    do_co2_val(values, 0)
  end

  def do_co2_val([val | []], _),
      do: val
          |> Enum.join()
          |> Integer.parse(2)
          |> elem(0)
  def do_co2_val(values, pos) do
    bit = least_common_bit_at_pos(values, pos)
    new_values = values
                 |> Enum.filter(
                      fn val ->
                        Enum.at(val, pos) == bit
                      end
                    )
    do_co2_val(new_values, pos + 1)
  end

  def most_common_bit_at_pos(values, pos) do
    counts = values
             |> transpose
             |> Enum.at(pos)
             |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    zero = Map.get(counts, "0")
    one = Map.get(counts, "1")

    case {one, zero} do
      {one, zero} when zero > one -> "0"
      _ -> "1"
    end
  end

  def least_common_bit_at_pos(values, pos) do
    counts = values
             |> transpose
             |> Enum.at(pos)
             |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    zero = Map.get(counts, "0")
    one = Map.get(counts, "1")

    IO.inspect({zero, one})
    case {one, zero} do
      {one, zero} when zero <= one -> "0"
      _ -> "1"
    end
  end

  def solve2(input) do
      ox = ox_val(input)
      co2 = co2_val(input)
      ox * co2
  end
end
