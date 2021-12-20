defmodule Day19 do
  use Utils.DayBoilerplate, day: 19

  def sample_input do
    """
    --- scanner 0 ---
    404,-588,-901
    528,-643,409
    -838,591,734
    390,-675,-793
    -537,-823,-458
    -485,-357,347
    -345,-311,381
    -661,-816,-575
    -876,649,763
    -618,-824,-621
    553,345,-567
    474,580,667
    -447,-329,318
    -584,868,-557
    544,-627,-890
    564,392,-477
    455,729,728
    -892,524,684
    -689,845,-530
    423,-701,434
    7,-33,-71
    630,319,-379
    443,580,662
    -789,900,-551
    459,-707,401

    --- scanner 1 ---
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    95,138,22
    -476,619,847
    -340,-569,-846
    567,-361,727
    -460,603,-452
    669,-402,600
    729,430,532
    -500,-761,534
    -322,571,750
    -466,-666,-811
    -429,-592,574
    -355,545,-477
    703,-491,-529
    -328,-685,520
    413,935,-424
    -391,539,-444
    586,-435,557
    -364,-763,-893
    807,-499,-711
    755,-354,-619
    553,889,-390

    --- scanner 2 ---
    649,640,665
    682,-795,504
    -784,533,-524
    -644,584,-595
    -588,-843,648
    -30,6,44
    -674,560,763
    500,723,-460
    609,671,-379
    -555,-800,653
    -675,-892,-343
    697,-426,-610
    578,704,681
    493,664,-388
    -671,-858,530
    -667,343,800
    571,-461,-707
    -138,-166,112
    -889,563,-600
    646,-828,498
    640,759,510
    -630,509,768
    -681,-892,-333
    673,-379,-804
    -742,-814,-386
    577,-820,562

    --- scanner 3 ---
    -589,542,597
    605,-692,669
    -500,565,-823
    -660,373,557
    -458,-679,-417
    -488,449,543
    -626,468,-788
    338,-750,-386
    528,-832,-391
    562,-778,733
    -938,-730,414
    543,643,-506
    -524,371,-870
    407,773,750
    -104,29,83
    378,-903,-323
    -778,-728,485
    426,699,580
    -438,-605,-362
    -469,-447,-387
    509,732,623
    647,635,-688
    -868,-804,481
    614,-800,639
    595,780,-596

    --- scanner 4 ---
    727,592,562
    -293,-554,779
    441,611,-461
    -714,465,-776
    -743,427,-804
    -660,-479,-426
    832,-632,460
    927,-485,-438
    408,393,-506
    466,436,-512
    110,16,151
    -258,-428,682
    -393,719,612
    -211,-452,876
    808,-476,-593
    -575,615,604
    -485,667,467
    -680,325,-822
    -627,-443,-432
    872,-547,-609
    833,512,582
    807,604,487
    839,-516,451
    891,-625,532
    -652,-548,-490
    30,-46,-14
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

  @doc"""
  There are two things about a scanners coordinate system that can be different, the relative order of the 3 dimensions
  and whether a particular dimension is inverted.

  We represent the the dimension order with a list of indices of the 'correct' frame
  We represent the inversion with a list of either 1 or -1 for each index
  """
  def coordinate_transforms do
    rotations = Comb.permutations([0, 1, 2])
    inversions = Comb.selections([1, -1], 3)

    Comb.cartesian_product(rotations, inversions)
  end

  @doc"""
  I call these 'rotation' and 'inversion' but that's not really true.

  For each index in the rotation list, we select the correct value in the absolute frame
  Then we zip with the inversions and multiply
  """
  def apply_transform([x, y, z], [rotation, inversion]) do
    rotation
    |> Enum.map(
         fn
           0 -> x
           1 -> y
           2 -> z
         end
       )
    |> Enum.zip(inversion)
    |> Enum.map(fn {val, inversion} -> val * inversion end)
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

  I had a bug here where I just made two sets from the combined distances, where I should be taking
  a union (i.e. in both scans)
  """
  def get_overlapping_points(scan1, scan2) do
    get_distance = fn {_, _, d} -> d end
    s1 = MapSet.new(Enum.map(scan1.pairs, get_distance))
    s2 = MapSet.new(Enum.map(scan2.pairs, get_distance))

    overlap = MapSet.intersection(s1, s2)
  end

  def pairs_to_map_by_distance(pairs) do
    for {p1, p2, distance} <- pairs, into: %{}, do: {distance, {p1, p2}}
  end

  @doc"""
  Determines the coordinate transform and offset to map `scan2`s coordinate system to `scan1`

  We assume that by this point it's already been decided that these do sufficiently overlap

  for now, I am doing this the 'dumb' way. We know it must be one of the 48 transforms, so try
  'em all.

  Okay but like, what does it even 'mean' to test? Well, we have our reference frame of scan1
  and 48 transformations of our point from scan2. Once we have fixed the rotation, it will just
  be an offset along each axis.

  The issue is, okay cool we've transformed but how do we know that's the correct one? I don't think
  we can with a single pair. So lets test the entire set of distances with each transform.

  So now we have a list of reference pairs, a list of transformed pairs and need to determine if our
  transform worked. Lets assume the transform did work. In that case, the delta between every x will match
  and so on. So we just check if that happened.
  """
  def find_transform_and_offset(scan1, scan2) do
    transforms = coordinate_transforms()

    if scans_overlap?(scan1, scan2) do
      transforms
      |> Enum.map(fn transform -> %{transform: transform, offset: test_transform(scan1, scan2, transform)} end)
      |> Enum.filter(fn x -> x.offset end)
    else
      nil
    end
  end

  @doc"""
  if each pair that overlaps produces the same offset, we probably have the correct transform
  """
  def test_transform(scan1, scan2, transform) do
    distances = get_overlapping_points(scan1, scan2)
    m1 = pairs_to_map_by_distance(scan1.pairs)
    m2 = pairs_to_map_by_distance(scan2.pairs)

    overlaps1 = distances
                |> Enum.map(&Map.get(m1, &1))
    overlaps2 = distances
                |> Enum.map(&Map.get(m2, &1))
                |> Enum.map(fn {a, b} -> {apply_transform(a, transform), apply_transform(b, transform)} end)

    set = Enum.zip(overlaps1, overlaps2)
          |> Enum.map(&calculate_offset/1)
          |> Enum.map(&get_viable_offset/1)
          |> MapSet.new()


    if MapSet.size(set) == 1 do
      value = hd(MapSet.to_list(set))
      if value == nil, do: false, else: value
    else
      false
    end
  end


  @doc"""
  a viable offset is one that could work, e.g. a pair of offsets that match
  """
  def get_viable_offset({{a, b}, {c, d}}) do
    cond do
      a == b -> a
      c == d -> c
      true -> nil
    end
  end

  @doc"""
  this one is a bit weird because we don't know for sure which order the pair is in, so we calculate both
  options. The idea being we can filter out above
  """
  def calculate_offset(pair = {{a1, a2}, {b1, b2}}) do
    a = diff_point(a1, b1)
    b = diff_point(a2, b2)
    c = diff_point(a1, b2)
    d = diff_point(a2, b1)

    {{a, b}, {c, d}}
  end

  def diff_point(p1, p2) do
    Enum.zip(p1, p2)
    |> Enum.map(fn {a, b} -> a - b end)
  end

  @doc"""
  A scan is overlapping if at least 12 points are shared within the scan
  """
  def scans_overlap?(scan1, scan2) do
    Enum.count(get_overlapping_points(scan1, scan2)) >= 12
  end

  @doc"""
  for each scan, get all the pairs and the data conserved in coordinate transform
    to start, just doing distance. These are linear transforms so we can do more I guess

  starting with the first scan and the second, find all pairs that share conserved data

  given those list of points that share data, attempt all possible coordinate transforms, find the one
  that works for all pairs with matching conserved data.

  For a given combination of scans, once we find the transform. A transform is a linear transformation represented
  by the [turn, flip] lists like we generated earlier. if we have, for example scan4 -> scan8 already solved
  and we find scan0 (absolute) -> scan8, we can then compute scan4 in absolute terms

  Once we have each scan specified in absolute terms, we have specified the entire set of beacons and can deduplicate.

  we transform all points in each scan and
  add them to a set. Once we have processed each combination that set should have the complete list of
  unique beacons
  """
  def solve(input) do
    scans = input_to_scans(input)
    scans_map = for scan <- scans, into: %{}, do: {scan.scan, scan}
    align_scan_cubes(scans_map)
  end


  @doc"""
  At this point, we have a way to determine if a scan overlaps the other.

  Given that, we should start at our reference scan (scan 0) and recursively map the remaining scans.

  We can define all the relations in one pass then assemble the transforms recursively
  """
  def align_scan_cubes(scans_map) do
    scans = Map.values(scans_map)
    alignment_map = Comb.combinations(scans, 2)
    |> Enum.map(fn [a, b] -> {a.scan, b.scan, find_transform_and_offset(a, b)} end)
    |> Enum.filter(fn {_, _, transform} -> transform != nil end)
    |> Enum.map(fn {a, b, transform} -> {{a, b}, transform} end)
    |> Map.new

    generate_edges(alignment_map)
  end

  def generate_edges(alignment_map) do
    Map.keys(alignment_map)
    |> Enum.map(fn {a,b} -> {b, a} end)
    |> Map.new()
  end

  def get_path(edges, node) do
    do_get_path(edges, [node])
  end

  def do_get_path(edges, path = [h | t]) when h == 0, do: path
  def do_get_path(edges, path = [h | t]) do
    do_get_path(edges, [Map.get(edges, h) | path])
  end
end
