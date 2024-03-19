defmodule Semetary.Sup do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Semetary.Rate, [nil]},
      {DynamicSupervisor, strategy: :one_for_one, name: MomSupervisor},
      {Semetary.BoardDad, [nil]},
      {Semetary.Sonky.Pool, [nil]}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
