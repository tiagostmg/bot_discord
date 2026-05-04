defmodule BotDiscordTest do
  use ExUnit.Case
  doctest BotDiscord

  test "greets the world" do
    assert BotDiscord.hello() == :world
  end
end
