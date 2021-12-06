defmodule Day6 do
  use Utils.DayBoilerplate, day: 6

  def sample_input do
    """
    3,4,3,1,2
    """
  end

  def parse_input(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def run_for_days(initial_fish, days) do
    {:ok, sub} = Submarine.start_link(initial_fish);
    1..days
    |> Enum.each(fn day ->
      IO.inspect(day)
#      IO.inspect(Submarine.count_fish(sub))
      Submarine.day_tick(sub)
    end)

    {sub, Submarine.count_fish(sub)}
  end

  def solve(input) do
    run_for_days(input, 80)
  end
end


defmodule Submarine do
  use GenServer

  def start_link(initial_fish) do
    {:ok, pid} = GenServer.start(__MODULE__, [])
    initial_fish
    |> Enum.map(&Lanternfish.start_link(pid, &1))

    {:ok, pid}
  end

  def day_tick(pid) do
    GenServer.call(pid, :day_tick, 20000)
  end

  def get_timers(pid) do
    GenServer.call(pid, :get_timers)
  end

  def count_fish(pid) do
    GenServer.call(pid, :count_fish)
  end

  def register_fish(pid, fish_pid) do
    GenServer.cast(pid, {:register_fish, fish_pid})
  end

  @impl true
  def init() do
    {:ok, []}
  end

  @impl true
  def handle_call(:day_tick, _from, fish) do
    fish
    |> Enum.map(&GenServer.call(&1, :day_tick))

    {:reply, nil, fish}
  end

  @impl true
  def handle_call(:get_timers, _from, fish) do
    results = fish
              |> Enum.map(fn server -> Task.async(fn -> GenServer.call(server, :get_timer) end) end)
              |> Enum.map(&Task.await/1)

    {:reply, results, fish}
  end

  @impl true
  def handle_call(:count_fish, _from, fish) do
    count = Enum.count(fish)

    {:reply, count, fish}
  end

  @impl true
  def handle_cast({:register_fish, pid}, fish) do
    {:noreply, [pid | fish]}
  end
end

defmodule Lanternfish do
  use GenServer

  ### Client
  def start_link(submarine_process, initial_timer \\ 8) do
    {:ok, pid} = GenServer.start(__MODULE__, {submarine_process, initial_timer})
    Submarine.register_fish(submarine_process, pid)

    {:ok, pid}
  end

  def day_tick(pid) do
    GenServer.call(pid, :day_tick)
  end

  def get_timer(pid) do
    GenServer.call(pid, :get_timer)
  end

  ### Server

  @impl true
  def init({pid, timer}) do
    {:ok, {pid, timer}}
  end

  @impl true
  def handle_call(:get_timer, from, state = {_, timer}) do
    {:reply, timer, state}
  end

  @impl true
  def handle_call(:day_tick, _from, {submarine_process, 0}) do
    create_new_fish(submarine_process)
    {:reply, nil, {submarine_process, 6}}
  end

  @impl true
  def handle_call(:day_tick, _from, {submarine_process, timer}) do
    {:reply, nil, {submarine_process, timer - 1}}
  end

  @impl true
  def handle_cast(:day_tick, {submarine_process, 0}) do
    create_new_fish(submarine_process)
    {:noreply, {submarine_process, 6}}
  end

  @impl true
  def handle_cast(:day_tick, {submarine_process, timer}) do
    {:noreply, {submarine_process, timer - 1}}
  end

  def create_new_fish(submarine_process) do
    {:ok, pid} = Lanternfish.start_link(submarine_process)
  end
end
