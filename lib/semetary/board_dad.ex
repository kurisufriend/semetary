defmodule Semetary.BoardDad do
  use GenServer

  def start_link(a) do
    GenServer.start_link(__MODULE__, a)
  end

  @impl true
  def init(a) do
    ["jp"]
    |> Enum.each(fn board ->
      DynamicSupervisor.start_child(
        MomSupervisor, {DynamicSupervisor, strategy: :one_for_one, name: String.to_atom(board<>"BoardSupervisor")}
      )
      DynamicSupervisor.start_child(MomSupervisor, {Semetary.BoardGS, %Semetary.Imageboard.Board{board: board, threads: %{}}})
    end)
    {:ok, a}
  end
end
