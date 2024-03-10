defmodule SemetaryTest do
  use ExUnit.Case
  doctest Semetary

  test "greets the world" do
    assert Semetary.hello() == :world
  end
end
