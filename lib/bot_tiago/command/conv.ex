defmodule BotTiago.Command.Conv do
  @moduledoc false

  @api_url "https://api.frankfurter.app/latest"

  def handle_conv(msg) do
    case String.split(msg.content, ~r/\s+/, trim: true) do
      ["!conv", amount, from_currency, to_currency] ->
        execute(amount, from_currency, to_currency)

      _ ->
        "uso: !conv [valor] [moeda_origem] [moeda_destino]"
    end
  end

  def execute(amount, from_currency, to_currency) do
    with {:ok, parsed_amount} <- parse_amount(amount),
         from <- String.upcase(from_currency),
         to <- String.upcase(to_currency),
         {:ok, response} <- request_conversion(parsed_amount, from, to) do
      response
    else
      {:error, :invalid_amount} ->
        "o valor precisa ser numerico. exemplo: !conv 100 USD BRL"

      {:error, message} when is_binary(message) ->
        message
    end
  end

  defp parse_amount(amount) do
    case Float.parse(amount) do
      {value, ""} when value > 0 -> {:ok, value}
      _ -> {:error, :invalid_amount}
    end
  end

  defp request_conversion(amount, from, to) do
    url = "#{@api_url}?amount=#{amount}&from=#{from}&to=#{to}"

    case HTTPoison.get(url, [], recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} -> format_conversion(body, amount, from, to)
      {:ok, %{status_code: status}} -> {:error, "nao consegui converter agora. status HTTP #{status}."}
      {:error, _reason} -> {:error, "falha ao consultar a API de cambio."}
    end
  end

  defp format_conversion(body, amount, from, to) do
    with {:ok, decoded} <- Jason.decode(body),
         %{} = rates <- decoded["rates"],
         converted when is_number(converted) <- rates[to] do
      {:ok, "#{format_decimal(amount)} #{from} = #{format_decimal(converted)} #{to}"}
    else
      _ -> {:error, "nao consegui interpretar a resposta da API de cambio."}
    end
  end

  defp format_decimal(number) do
    :erlang.float_to_binary(number * 1.0, decimals: 2)
  end
end
