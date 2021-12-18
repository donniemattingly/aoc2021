defmodule Day18Test do
  use ExUnit.Case, async: true
  import Day18

  def test_explosion(input, expected) do
    assert parse_snailfish_number(input)
           |> explode
           |> render_snailfish_number == expected
  end

  def test_split(input, expected) do
    assert parse_snailfish_number(input)
           |> split
           |> render_snailfish_number == expected
  end

  def test_add(a, b, expected) do
    assert add(parse_snailfish_number(a), parse_snailfish_number(b))
           |> render_snailfish_number == expected
  end

  def test_solve(list, expected) do
    assert list
           |> parse_input
           |> solve
           |> render_snailfish_number == expected
  end

  test "explosion - 1" do
    test_explosion(
      [[[[[9, 8], 1], 2], 3], 4],
      [[[[0, 9], 2], 3], 4]
    )
  end

  test "explosion - 2" do
    test_explosion(
      [7, [6, [5, [4, [3, 2]]]]],
      [7, [6, [5, [7, 0]]]]
    )
  end

  test "explosion - 3" do
    test_explosion(
      [[6, [5, [4, [3, 2]]]], 1],
      [[6, [5, [7, 0]]], 3]
    )
  end

  test "explosion - 4" do
    test_explosion(
      [[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]],
      [[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]]
    )
  end

  test "explosion - 5" do
    test_explosion(
      [[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]],
      [[3, [2, [8, 0]]], [9, [5, [7, 0]]]]
    )
  end

  test "split - 1 " do
    test_split(
      [1, 10],
      [1, [5, 5]]
    )
  end

  test "reduce steps" do
    # Step 1
    test_explosion(
      [[[[[4, 3], 4], 4], [7, [[8, 4], 9]]], [1, 1]],
      [[[[0, 7], 4], [7, [[8, 4], 9]]], [1, 1]]
    )

    # Step 2
    test_explosion(
      [[[[0, 7], 4], [7, [[8, 4], 9]]], [1, 1]],
      [[[[0, 7], 4], [15, [0, 13]]], [1, 1]]
    )

    # Step 3
    test_split(
      [[[[0, 7], 4], [15, [0, 13]]], [1, 1]],
      [[[[0, 7], 4], [[7, 8], [0, 13]]], [1, 1]]
    )

    # Step 4
    test_split(
      [[[[0, 7], 4], [[7, 8], [0, 13]]], [1, 1]],
      [[[[0, 7], 4], [[7, 8], [0, [6, 7]]]], [1, 1]]
    )

    # Step 5
    test_explosion(
      [[[[0, 7], 4], [[7, 8], [0, [6, 7]]]], [1, 1]],
      [[[[0, 7], 4], [[7, 8], [6, 0]]], [8, 1]]
    )
  end

  test "add - 1 " do
    test_add(
      [[[[4, 3], 4], 4], [7, [[8, 4], 9]]],
      [1, 1],
      [[[[0, 7], 4], [[7, 8], [6, 0]]], [8, 1]]
    )
  end

  test "list - 1" do
    test_solve(
      """
      [1,1]
      [2,2]
      [3,3]
      [4,4]
      """,
      [[[[1, 1], [2, 2]], [3, 3]], [4, 4]]
    )
  end

  test "list - 2" do
    test_solve(
      """
      [1,1]
      [2,2]
      [3,3]
      [4,4]
      [5,5]
      """,
      [[[[3, 0], [5, 3]], [4, 4]], [5, 5]]
    )
  end

  test "list - 3" do
    test_solve(
      """
          [1,1]
          [2,2]
          [3,3]
          [4,4]
          [5,5]
          [6,6]
      """,
      [[[[5, 0], [7, 4]], [5, 5]], [6, 6]]
    )
  end

  test "decomposed sample - 1" do
    test_add(
      [[[0, [4, 5]], [0, 0]], [[[4, 5], [2, 6]], [9, 5]]],
      [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]],
      [[[[4, 0], [5, 4]], [[7, 7], [6, 0]]], [[8, [7, 7]], [[7, 9], [5, 0]]]]
    )
  end

  test "decomposed sample - 2" do
    test_add(
      [[[[4, 0], [5, 4]], [[7, 7], [6, 0]]], [[8, [7, 7]], [[7, 9], [5, 0]]]],
      [[2, [[0, 8], [3, 4]]], [[[6, 7], 1], [7, [1, 6]]]],
      [[[[6, 7], [6, 7]], [[7, 7], [0, 7]]], [[[8, 7], [7, 7]], [[8, 8], [8, 0]]]]
    )
  end

  test "decomposed sample - 3" do
    test_add(
      [[[[6, 7], [6, 7]], [[7, 7], [0, 7]]], [[[8, 7], [7, 7]], [[8, 8], [8, 0]]]],
      [[[[2, 4], 7], [6, [0, 5]]], [[[6, 8], [2, 8]], [[2, 1], [4, 5]]]],
      [[[[7, 0], [7, 7]], [[7, 7], [7, 8]]], [[[7, 7], [8, 8]], [[7, 7], [8, 7]]]]
    )
  end

  test "decomposed sample - 4" do
    test_add(
      [[[[7, 0], [7, 7]], [[7, 7], [7, 8]]], [[[7, 7], [8, 8]], [[7, 7], [8, 7]]]],
      [7, [5, [[3, 8], [1, 4]]]],
      [[[[7, 7], [7, 8]], [[9, 5], [8, 7]]], [[[6, 8], [0, 8]], [[9, 9], [9, 0]]]]
    )
  end

  test "decomposed sample - 5" do
    test_add(
      [[[[7, 7], [7, 8]], [[9, 5], [8, 7]]], [[[6, 8], [0, 8]], [[9, 9], [9, 0]]]],
      [[2, [2, 2]], [8, [8, 1]]],
      [[[[6, 6], [6, 6]], [[6, 0], [6, 7]]], [[[7, 7], [8, 9]], [8, [8, 1]]]]
    )
  end

  test "decomposed sample - 6" do
    test_add(
      [[[[6, 6], [6, 6]], [[6, 0], [6, 7]]], [[[7, 7], [8, 9]], [8, [8, 1]]]],
      [2, 9],
      [[[[6, 6], [7, 7]], [[0, 7], [7, 7]]], [[[5, 5], [5, 6]], 9]]
    )
  end

  test "decomposed sample - 7" do
    test_add(
      [[[[6, 6], [7, 7]], [[0, 7], [7, 7]]], [[[5, 5], [5, 6]], 9]],
      [1, [[[9, 3], 9], [[9, 0], [0, 7]]]],
      [[[[7, 8], [6, 7]], [[6, 8], [0, 8]]], [[[7, 7], [5, 0]], [[5, 5], [5, 6]]]]
    )
  end

  test "decomposed sample - 8" do
    test_add(
      [[[[7, 8], [6, 7]], [[6, 8], [0, 8]]], [[[7, 7], [5, 0]], [[5, 5], [5, 6]]]],
      [[[5, [7, 4]], 7], 1],
      [[[[7, 7], [7, 7]], [[8, 7], [8, 7]]], [[[7, 0], [7, 7]], 9]]
    )
  end

  test "decomposed sample - 9" do
    test_add(
      [[[[7, 7], [7, 7]], [[8, 7], [8, 7]]], [[[7, 0], [7, 7]], 9]],
      [[[[4, 2], 2], 6], [8, 7]],
      [[[[8, 7], [7, 7]], [[8, 6], [7, 7]]], [[[0, 7], [6, 6]], [8, 7]]]
    )
  end

end