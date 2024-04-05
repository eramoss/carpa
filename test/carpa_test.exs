defmodule CarpaTest do
  use ExUnit.Case
  doctest Carpa

  test "greets the world" do
    assert Carpa.hello() == :world
  end
end
