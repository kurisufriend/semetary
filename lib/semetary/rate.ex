defmodule Semetary.Rate do
  use GenServer

  @time 100

  def start_link(last_activity) do
    GenServer.start_link(__MODULE__, last_activity, name: :ratelimiter)
  end

  @impl true
  def init(last_activity) do
    last_activity = :os.system_time(:millisecond)
    {:ok, last_activity}
  end

  @impl true
  def handle_call(:activate, _, last_activity) do
    if :os.system_time(:millisecond) - last_activity > @time do
      last_activity = :os.system_time(:millisecond)
      {:reply, :goahead, last_activity}
    else
      {:reply, :defer, last_activity}
    end
  end
end
