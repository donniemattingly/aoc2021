defmodule Day18Test do
  use ExUnit.Case, async: true

  test "explodes" do
    assert [[[[[9,8],1],2],3],4] |> Day18.parse_snailfish_number() == 0
  end
end