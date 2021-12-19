defmodule Day19 do
  use Utils.DayBoilerplate, day: 19

  def sample_input do
    """
    --- scanner 0 ---
    0,2,0
    4,1,0
    3,3,0

    --- scanner 1 ---
    -1,-1,0
    -5,0,0
    -2,1,0
    """
  end

  def parse_input(input) do
    input
    |> String.split(~r/--- scanner \d+ ---/, trim: true)
    |> Enum.map(
         fn scanner ->
           Utils.split_and_parse_lines(
             scanner,
             fn a ->
               String.split(a, ",", trime: true)
               |> Enum.map(&String.to_integer/1)
             end
           )
         end
       )
  end

  def calculate_conserved_data(beacons) do
    beacons
    |> Comb.combinations(2)
    |> Enum.map(fn [a, b] -> {a, b, Day19.distance(a, b)} end)
  end

  def distance(p1, p2) do
    euclidean_distance(p1, p2)
  end

  def euclidean_distance(p1, p2) do
    Enum.zip(p2, p1)
    |> Enum.map(fn {a, b} -> a - b end)
    |> Enum.map(&:math.pow(&1, 2))
    |> Enum.sum()
    |> :math.sqrt()
    |> Float.round(3)
  end

  def coordinate_transforms do
    rotations = Comb.permutations([0, 1, 2])
    inversions = Comb.selections([1, -1], 3)

    Comb.cartesian_product(rotations, inversions)
  end

  def create_scan(beacons, pairs, scan_number) do
    %{
      scan: scan_number,
      beacons: beacons,
      pairs: pairs
    }
  end

  @doc"""
  Takes `input` which is a list of lists, the parent being a list of scans and the children being the
  detected beacons. For each scan it calculates the conserved data pairs and creates a scans map

  Returns a list of scan maps
  """
  def input_to_scans(input) do
    input
    |> Utils.pmap(&calculate_conserved_data/1)
    |> Enum.zip(input)
    |> Utils.List.zip_with_index()
    |> Enum.map(fn {{pairs, beacons}, index} -> create_scan(beacons, pairs, index) end)
  end

  @doc"""
  takes two scans and finds points that overlap. Uses the already computed pairs w/ distance

  we make a map of distances to pair for each scan, then do a set intersection of each maps keys
  """
  def get_overlapping_points(scan1, scan2) do
    m1 = pairs_to_map_by_distance(scan1.pairs)
    m2 = pairs_to_map_by_distance(scan2.pairs)

    overlap = MapSet.new(Map.keys(m1) ++ Map.keys(m2))
  end

  def pairs_to_map_by_distance(pairs) do
    for {p1, p2, distance} <- pairs, into: %{}, do: {distance, {p1, p2}}
  end

  @doc"""
  Determines the coordinate transform and offset to map `scan2`s coordinate system to `scan1`
  """
  def find_transform_and_offset(scan1, scan2) do
    get_overlapping_points(scan1, scan2)
  end

  @doc"""
  for each scan, get all the pairs and the data conserved in coordinate transform
    to start, just doing distance. These are linear transforms so we can do more I guess

  starting with the first scan and the second, find all pairs that share conserved data

  given those list of points that share data, attempt all possible coordinate transforms, find the one
  that works for all pairs with matching conserved data.

  For a given combination of scans, once we find the transform, we transform all points in that scan and
  add them to a set. Once we have processed each combination that set should have the complete list of
  unique beacons
  """
  def solve(input) do
    scans = input_to_scans(input)
  end
end
