defmodule TwetchTest do
  use ExUnit.Case
  doctest Twetch

  test "greets the world" do
    assert Twetch.hello() == :world
  end
end
