defmodule Semetary.Rate do
  use GenServer

  @time 1000
  @global_time 10

  def start_link(last_activity_map) do
    GenServer.start_link(__MODULE__, last_activity_map, name: :ratelimiter)
  end

  @impl true
  def init(last_activity_map) do
    last_activity_map = (MapSet.new() |> Map.put("global", :os.system_time(:millisecond)))
    {:ok, last_activity_map}
  end

  @impl true
  def handle_call({:activate, pool}, _, last_activity_map) do
    {_, last_activity_map} = last_activity_map
      |> Map.get_and_update(pool, fn cur ->
        if cur != nil, do: {cur, cur}, else: {cur, :os.system_time(:millisecond)}
      end)
    if :os.system_time(:millisecond) - Map.get(last_activity_map, pool) > @time
    and :os.system_time(:millisecond) - Map.get(last_activity_map, "global") > @global_time do
      last_activity_map = (Map.put(last_activity_map, pool, :os.system_time(:millisecond)) |>
      Map.put("global", :os.system_time(:millisecond)))
      {:reply, :goahead, last_activity_map}
    else
      {:reply, :defer, last_activity_map}
    end
  end

  def rated_get!(uri, pool \\ :noproxy, opts \\ []) do
    if GenServer.call(:ratelimiter, {:activate, pool}) == :goahead do
      try do
        Semetary.Sonky.proxied_get!(uri, pool, opts)
      rescue e ->
        IO.puts("yo, shit #{uri} failed w, retrying")
        IO.inspect(e)
        Process.sleep(100)
        rated_get!(uri, pool, opts)
      end
    else
      Process.sleep(100)
      rated_get!(uri, pool, opts)
    end
  end
end
