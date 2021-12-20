defmodule Day20 do
  use Utils.DayBoilerplate, day: 20

  def sample_input do
    """
    ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

    #..#.
    #....
    ##..#
    ..#..
    ..###
    """
  end

  def parse_input(input) do
    [enhance, image] = String.split(input, "\n\n")

    %{
      image: parse_image(image),
      algo: parse_algorithm(enhance)
    }
  end

  def parse_algorithm(algo_str) do
    Utils.split_each_char(algo_str)
    |> Utils.List.zip_with_index()
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> Map.new
  end

  def neighbors({px, py}) do
    for y <- -1..1, x <- -1..1, do: {x + px, y + py}
  end

  def pixel_list_to_binary(list) do
    Enum.map(
      list,
      fn
        "." -> 0
        "#" -> 1
      end
    )
    |> Convert.binary_list_to_integer()
  end

  def get_value_for_pixel(pixel, image, algorithm, num) do
    default = if rem(num, 2) == 0, do: "#", else: "."
    value = pixel
            |> neighbors
            |> Enum.map(
                 &Map.get(
                   image,
                   &1,
                   default
                 )
               )
            |> pixel_list_to_binary

    Map.get(algorithm, value)
  end

  def parse_image(image_str) do
    image_str
    |> Utils.split_and_parse_lines(&Utils.split_each_char/1)
    |> Utils.list_of_lists_to_map_by_point()
  end

  def iteration(image, algo, num) do
    {{a, b}, {c, d}} = Map.keys(image)
                       |> Enum.min_max

    pad = 3
    result = for x <- (a - pad)..(c + pad), y <- (b - pad)..(d + pad),
                 into: %{},
                 do: {{x, y}, get_value_for_pixel({x, y}, image, algo, num)}

    result
  end

  def solve(%{image: image, algo: algo}) do

    image
    |> iteration(algo, 1)
    |> iteration(algo, 2)
    |> Map.to_list
    |> Enum.filter(fn {k, v} -> v == "#" end)
    |> Enum.count
  end

  def solve2(%{image: image, algo: algo}) do
    1..50
    |> Enum.reduce(image, fn x, acc -> iteration(acc, algo, x) end)
    |> Map.to_list
    |> Enum.filter(fn {k, v} -> v == "#" end)
    |> Enum.count
  end
end
