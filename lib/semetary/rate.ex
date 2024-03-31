defmodule Semetary.Rate do
  use GenServer

  @time 1000

  def start_link(last_activity_map) do
    GenServer.start_link(__MODULE__, last_activity_map, name: :ratelimiter)
  end

  @impl true
  def init(last_activity_map) do
    last_activity_map = MapSet.new()
    {:ok, last_activity_map}
  end

  @impl true
  def handle_call({:activate, pool}, _, last_activity_map) do
    {_, last_activity_map} = last_activity_map
      |> Map.get_and_update(pool, fn cur ->
        if cur != nil, do: {cur, cur}, else: {cur, :os.system_time(:millisecond)}
      end)
    if :os.system_time(:millisecond) - Map.get(last_activity_map, pool) > @time do
      last_activity_map = Map.put(last_activity_map, pool, :os.system_time(:millisecond))
      {:reply, :goahead, last_activity_map}
    else
      {:reply, :defer, last_activity_map}
    end
  end
end
