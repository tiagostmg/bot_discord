defmodule BotTiago.Command.Github do
  @moduledoc false

  @github_url "https://api.github.com/users"
  @headers [{"user-agent", "bot-tiago"}]

  def handle_github(msg) do
    case String.split(msg.content, ~r/\s+/, trim: true) do
      ["!github", username] -> execute(username)
      _ -> "uso: !github [usuario]"
    end
  end

  def execute(username) do
    url = "#{@github_url}/#{URI.encode(username)}"

    case HTTPoison.get(url, @headers, recv_timeout: 10_000) do
      {:ok, %{status_code: 200, body: body}} ->
        format_profile(body)

      {:ok, %{status_code: 404}} ->
        "usuario #{username} nao encontrado no GitHub."

      {:ok, %{status_code: status}} ->
        "nao consegui consultar o GitHub agora. status HTTP #{status}."

      {:error, _reason} ->
        "falha ao consultar a API do GitHub para #{username}."
    end
  end

  defp format_profile(body) do
    with {:ok, decoded} <- Jason.decode(body),
         login when is_binary(login) <- decoded["login"],
         html_url when is_binary(html_url) <- decoded["html_url"] do
      repos = decoded["public_repos"] || 0
      bio = decoded["bio"] || "sem bio informada."
      "#{login}: #{html_url} | repos publicos: #{repos} | bio: #{bio}"
    else
      _ -> "nao consegui interpretar a resposta do GitHub."
    end
  end
end
