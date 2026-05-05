defmodule BotTiago do
  use Nostrum.Consumer

  alias Nostrum.Api.Message
  alias BotTiago.Command.Clima
  alias BotTiago.Command.Conv
  alias BotTiago.Command.Curiosidade
  alias BotTiago.Command.Dado
  alias BotTiago.Command.Github
  alias BotTiago.Command.Lembrar

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    if msg.author.bot do
      :ignore
    else
      case String.split(msg.content, ~r/\s+/, trim: true) do
        ["!ping"] ->
          Message.create(msg.channel_id, "pong! bot online e conectado.")

        ["!status"] ->
          Message.create(msg.channel_id, "status: online, websocket ativo.")

        ["!clima" | _] ->
          Message.create(msg.channel_id, Clima.handle_clima(msg))

        ["!github" | _] ->
          Message.create(msg.channel_id, Github.handle_github(msg))

        ["!conv" | _] ->
          Message.create(msg.channel_id, Conv.handle_conv(msg))

        ["!dado" | _] ->
          Message.create(msg.channel_id, Dado.handle_dado(msg))

        ["!lembrar" | _] ->
          Message.create(msg.channel_id, Lembrar.handle_lembrar(msg))

        ["!meuslembretes"] ->
          Message.create(msg.channel_id, Lembrar.handle_meus_lembretes(msg))

        ["!curiosidade"] ->
          Message.create(msg.channel_id, Curiosidade.handle_curiosidade(msg))

        _ ->
          :ignore
      end
    end
  end
end
