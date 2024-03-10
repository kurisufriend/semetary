defmodule Semetary.ThreadGS do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: String.to_atom(state.board<>to_string(state.no)<>"ThreadGS"))
  end

  @impl true
  def init(state) do
    IO.puts("watching thread "<>inspect(state))
    send(String.to_atom(state.board<>"BoardGS"), {:checkin, state.no, self()})
    send(self(), {:update, state.on_page, state.reply_number, true})
    {:ok, state}
  end

  @impl true
  def handle_info({:addpost, post}, state) do
    state = unless MapSet.member?(state.postsSet, post) do
      state = %Semetary.Imageboard.Thread{state | postsSet: state.postsSet |> MapSet.put(post)}
      Task.start(fn -> Semetary.Malsurrector.post_processing(post) end)
      # IO.puts(post["com"])
      state
    else
      # IO.puts("penis!")
      state
    end
    {:noreply, state}
  end

  @impl true
  def handle_info(:save, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:update, new_page, new_replynum, first_run}, state) do
    if (new_replynum > state.reply_number) or first_run do
      res = Semetary.Imageboard.thread(state.board, state.no)
      if res.status == 200 do
        res.body["posts"]
        |> Enum.each(fn post ->
          send(self(), {:addpost, post})
        end)
      else
        IO.puts("IM LEAVING BYE "<>inspect(state))
        DynamicSupervisor.terminate_child(String.to_atom(state.board<>"BoardSupervisor"), self())
        Process.exit(self(), :fourohfour)
      end
    end
    state = %Semetary.Imageboard.Thread{state | on_page: new_page, reply_number: new_replynum}
    send(self(), :save)
    {:noreply, state}
  end
end
