defmodule Semetary do
  use Application

  def start(_type, _args) do
    IO.puts("starting~")
    Semetary.Sup.start_link(name: :sup)
  end
end
