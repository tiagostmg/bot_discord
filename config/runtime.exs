import Config
import Dotenvy

source!([
  Path.absname(".env"),
  System.get_env()
])

config :nostrum,
  token: env!("DISCORD_TOKEN"),
  gateway_intents: :all,
  ffmpeg: false
