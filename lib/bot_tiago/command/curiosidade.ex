defmodule BotTiago.Command.Curiosidade do
  @moduledoc false

  @fact_url "https://catfact.ninja/fact"
  @image_url "https://api.thecatapi.com/v1/images/search"

  def handle_curiosidade(_msg) do
    with {:ok, fact} <- fetch_fact(),
         {:ok, image_url} <- fetch_image() do
      "curiosidade: #{fact} | imagem: #{image_url}"
    else
      {:error, message} -> message
    end
  end

  defp fetch_fact do
    case HTTPoison.get(@fact_url, [], recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"fact" => fact}} -> {:ok, fact}
          _ -> {:error, "nao consegui interpretar a API de curiosidades."}
        end

      {:ok, %{status_code: status}} ->
        {:error, "a API de curiosidades respondeu com status #{status}."}

      {:error, _reason} ->
        {:error, "falha ao consultar a API de curiosidades."}
    end
  end

  defp fetch_image do
    case HTTPoison.get(@image_url, [], recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, [%{"url" => url} | _]} -> {:ok, url}
          _ -> {:error, "nao consegui interpretar a API de imagens."}
        end

      {:ok, %{status_code: status}} ->
        {:error, "a API de imagens respondeu com status #{status}."}

      {:error, _reason} ->
        {:error, "falha ao consultar a API de imagens."}
    end
  end
end
