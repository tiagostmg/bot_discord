import Config

config :nostrum,
  token: System.fetch_env("DISCORD_BOT_TOKEN"),
  gateway_intents: :all,
  ffmpeg: false
