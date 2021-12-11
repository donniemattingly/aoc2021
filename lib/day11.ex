defmodule Day11 do
  use Utils.DayBoilerplate, day: 11

  def sample_input do
    """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_and_parse_lines(fn x -> Utils.split_and_parse_each_char(x, &String.to_integer/1) end)
    |> Utils.list_of_lists_to_map_by_point()
    |> Map.to_list
  end

  def solve(input) do
    {:ok, cavern} = Cavern.start_link(input)

    1..100
    |> Enum.each(fn _ -> Cavern.run_step(cavern) end)

    FlashCounter.state()
  end

  def solve2(input) do
    {:ok, cavern} = Cavern.start_link(input)

    [{_, idx}] = Stream.iterate(0, &(&1 + 1))
                 |> Stream.map(fn _ -> Cavern.run_step(cavern) end)
                 |> Stream.with_index()
                 |> Stream.filter(fn {count, index} -> count == 100 end)
                 |> Stream.take(1)
                 |> Enum.to_list();

    idx + 1
  end

  def is_adjacent({x1, y1}, {x2, y2}) do
    abs(x2 - x1) <= 1 and abs(y2 - y1) <= 1
  end
end


defmodule FlashCounter do
  use GenServer

  def start_link() do
    case Process.whereis(FlashCounter) do
      nil ->
        {:ok, pid} = GenServer.start_link(__MODULE__, 0)
        Process.register(pid, FlashCounter)
      _ ->
        IO.puts("FlashCounter already running, resetting")
        FlashCounter.reset()
    end
  end

  def increment() do
    GenServer.call(__MODULE__, :increment)
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  def handle_call(:increment, _from, state) do
    {:reply, :ok, state + 1}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, state) do
    {:reply, :ok, 0}
  end
end

defmodule Cavern do
  use GenServer

  ### Client
  def start_link(octopi_config) do
    octopi = octopi_config
             |> Enum.map(
                  fn config ->
                    {:ok, pid} = Octopus.start_link(config)
                    pid
                  end
                )

    points = octopi_config
             |> Enum.map(&elem(&1, 0))

    grid = Enum.zip(points, octopi)
           |> Map.new
    FlashCounter.start_link()
    GenServer.start_link(Cavern, grid)
  end

  def display(pid) do
    grid = state(pid)
    {{x1, y1}, {x2, y2}} = grid
                           |> Map.keys
                           |> Enum.min_max()
    y1..y2
    |> Enum.map(
         fn y ->
           x1..x2
           |> Enum.map(
                fn x ->
                  pid = Map.get(grid, {x, y})
                  {_, energy, _} = Octopus.state(pid)

                  energy
                end
              )
           |> Enum.join("")
         end
       )
    |> Enum.join("\n")
    |> IO.puts
  end

  def state(pid), do: GenServer.call(pid, :state)
  def run_step(pid), do: GenServer.call(pid, :run_step)
  ### Server

  def init(octopi) do
    {:ok, octopi}
  end

  def handle_call(:state, _caller, state) do
    {:reply, state, state}
  end


  def do_flashes(pids, []), do: :ok
  def do_flashes(pids, flashes) do
    pids
    |> Enum.map(
         fn pid ->
           flashes
           |> Enum.map(&Octopus.handle_flash(pid, &1))
         end
       )

    new_flashes = pids
                  |> Enum.map(&Octopus.do_flash/1)
                  |> Enum.filter(& &1)

    do_flashes(pids, new_flashes)
  end

  def do_run_step(grid) do
    pids = Map.values(grid)
    ### Increase all by 1
    pids
    |> Enum.map(&Octopus.start_step/1)
    flashes = pids
              |> Enum.map(&Octopus.do_flash/1)
              |> Enum.filter(& &1)

    :ok = do_flashes(pids, flashes)

    did_flash = pids
                |> Enum.map(&Octopus.state/1)
                |> Enum.map(&elem(&1, 2))
                |> Enum.count(& &1)

    pids
    |> Enum.map(&Octopus.reset/1)

    did_flash
  end

  def handle_call(:run_step, _caller, grid) do
    x = do_run_step(grid)
    {:reply, x, grid}
  end

end


defmodule Octopus do
  use GenServer

  ### Client
  def start_link({point, energy}), do: GenServer.start_link(Octopus, {point, energy})
  def start_step(pid), do: GenServer.call(pid, :start_step)
  def handle_flash(pid, from_point), do: GenServer.call(pid, {:handle_flash, from_point})
  def do_flash(pid), do: GenServer.call(pid, :do_flash)
  def reset(pid), do: GenServer.call(pid, :reset)
  def state(pid), do: GenServer.call(pid, :state)

  ### Server

  def init({point, energy}) do
    {:ok, {point, energy, false}}
  end

  def handle_call(:start_step, _caller, {point, energy, has_flashed}) do
    {:reply, energy + 1, {point, energy + 1, has_flashed}}
  end

  def handle_call({:handle_flash, from_point}, _caller, {point, energy, has_flashed}) do
    case Day11.is_adjacent(point, from_point) do
      true -> {:reply, energy + 1, {point, energy + 1, has_flashed}}
      false -> {:reply, energy, {point, energy, has_flashed}}
    end
  end

  def handle_call(:do_flash, _caller, {point, energy, has_flashed}) do
    can_flash = energy > 9
    case can_flash && !has_flashed do
      true ->
        FlashCounter.increment()
        {:reply, point, {point, energy, true}}
      false -> {:reply, nil, {point, energy, has_flashed}}
    end
  end

  def handle_call(:reset, _caller, {point, energy, true}), do: {:reply, 0, {point, 0, false}}
  def handle_call(:reset, _caller, {point, energy, has_flashed}), do: {:reply, energy, {point, energy, false}}

  def handle_call(:state, _caller, state), do: {:reply, state, state}
end
