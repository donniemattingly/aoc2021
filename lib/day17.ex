defmodule Day17 do
  use Utils.DayBoilerplate, day: 17

  def sample_input do
    """
    target area: x=20..30, y=-10..-5
    """
  end

  def parse_input(input) do
    [_, ranges] = String.split(input, ": ")
    [x, y] = String.split(ranges, ", ")
    {x_range, _} = Code.eval_string(x)
    {y_range, _} = Code.eval_string(y)

    {x_range, y_range}
  end

  def do_step({x, y, dx, dy}), do: {x + dx, y + dy, adjust_towards_zero(dx), dy - 1}

  def in_target(x_range, y_range, {x, y, _, _}), do: x in x_range and y in y_range

  def adjust_towards_zero(0), do: 0
  def adjust_towards_zero(val) when val > 0, do: val - 1
  def adjust_towards_zero(val) when val < 0, do: val + 1

  def test_velocity({dx, dy}, {x_range, y_range}) do
    s = 1..500
        |> Stream.scan({0, 0, dx, dy}, fn _, acc -> do_step(acc) end)

    y_max = Stream.map(s, fn {x, y, dx, dy} -> y end)
            |> Enum.max
    l = s
        |> Stream.filter(fn val -> in_target(x_range, y_range, val) end)
        |> Enum.to_list
        |> Enum.count

    case l do
      0 -> nil
      x -> y_max
    end
  end

  def solve({xr, yr}) do
    vs = for x <- 0..300, y <- -150..200, do: {x, y}
    vs
    |> Utils.pmap(fn v -> {v, test_velocity(v, {xr, yr})} end)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.max_by(&elem(&1, 1))
  end

  def solve2({xr, yr}) do
    vs = for x <- 0..300, y <- -200..200, do: {x, y}
    vs
    |> Utils.pmap(fn v -> {v, test_velocity(v, {xr, yr})} end)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.count
  end
end
