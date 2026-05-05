defmodule BotTiago do
  use Nostrum.Consumer

  alias Nostrum.Api.Message

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    cond do
      String.starts_with?(msg.content, "!ping") ->
        Message.create(msg.channel_id, "pong!")

      String.starts_with?(msg.content, "!ppt") ->
        Message.create(msg.channel_id, BotTiago.Command.Ppt.handle_ppt(msg))

      String.starts_with?(msg.content, "!cep") ->
        Message.create(msg.channel_id, BotTiago.Command.Cep.handle_cep(msg))

      String.starts_with?(msg.content, "!dog") ->
        Message.create(msg.channel_id, BotTiago.Command.Animal.handle_dog(msg))

      String.starts_with?(msg.content, "!cat") ->
        Message.create(msg.channel_id, BotTiago.Command.Animal.handle_cat(msg))

      true ->
        :ignore
    end
  end
end
