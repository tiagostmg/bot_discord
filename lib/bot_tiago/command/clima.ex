defmodule BotTiago.Command.Clima do
  @moduledoc false

  @weather_url "https://wttr.in"

  def handle_clima(msg) do
    msg.content
    |> String.trim()
    |> String.replace_prefix("!clima", "")
    |> String.trim()
    |> execute()
  end

  def execute(""), do: "uso: !clima [cidade]"

  def execute(city) do
    city
    |> build_url()
    |> HTTPoison.get([], recv_timeout: 10_000)
    |> format_response(city)
  end

  defp build_url(city) do
    encoded_city = URI.encode(city)
    "#{@weather_url}/#{encoded_city}?format=j1"
  end

  defp format_response({:ok, %{status_code: 200, body: body}}, city) do
    with {:ok, decoded} <- Jason.decode(body),
         %{"current_condition" => [current | _]} <- decoded,
         temp <- current["temp_C"],
         feels_like <- current["FeelsLikeC"],
         humidity <- current["humidity"],
         description <- get_in(current, ["weatherDesc", Access.at(0), "value"]) do
      "clima em #{city}: #{description}, #{temp}C, sensacao #{feels_like}C, umidade #{humidity}%."
    else
      _ -> "nao consegui interpretar a resposta da API de clima para #{city}."
    end
  end

  defp format_response({:ok, %{status_code: status}}, city) do
    "nao consegui consultar o clima de #{city}. status HTTP #{status}."
  end

  defp format_response({:error, _reason}, city) do
    "falha ao consultar a API de clima para #{city}. tente novamente em instantes."
  end
end
