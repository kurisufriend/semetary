defmodule Semetary.BoardGS do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: String.to_atom(state.board<>"BoardGS"))
  end

  @impl true
  def handle_info({:checkin, no, pid}, state) do
    state = %Semetary.Imageboard.Board{board: state.board, threads: Map.put(state.threads, no, pid)}
    {:noreply, state}
  end

  @impl true
  def handle_info(:update, state) do
    IO.puts("upd8ing "<>state.board)
    res = Semetary.Imageboard.threads(state.board)
    res.body
    |> Enum.each(fn page ->
      Enum.each(page["threads"], fn thread ->
        if state.threads[thread["no"]] == nil do
          DynamicSupervisor.start_child(
            String.to_atom(state.board<>"BoardSupervisor"),
            {
              Semetary.ThreadGS,
              %Semetary.Imageboard.Thread{
                board: state.board,
                no: thread["no"],
                last_update: thread["last_modified"],
                reply_number: thread["replies"],
                on_page: page["page"]
              }
            }
          )
        else
          try do
            send(String.to_atom(state.board<>to_string(thread["no"])<>"ThreadGS"), {:update, page["page"], thread["replies"], false})
          rescue e ->
            IO.puts("failed to send update signal to thread #{state.board}/"<>to_string(thread["no"])<>" could it be a sticky or something?")
            IO.inspect(e)
          end
        end
      end)
    end)
    {:noreply, state}
  end

  def go_forever(proc) do
    send(proc, :update)
    Process.sleep(60_000)
    go_forever(proc)
  end

  @impl true
  def init(state) do
    IO.puts("started BoardGS to archive board "<>state.board)
    Task.start_link(fn -> go_forever(String.to_atom(state.board<>"BoardGS")) end)
    {:ok, state}
  end
end
