defmodule BotTiago.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    load_dotenv()

    children = [
      # Starts a worker by calling: BotTiago.Worker.start_link(arg)
      # {BotTiago.Worker, arg}
      BotTiago
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BotTiago.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp load_dotenv do
    Dotenv.load()
    Mix.Task.run("loadconfig")
  end
end
