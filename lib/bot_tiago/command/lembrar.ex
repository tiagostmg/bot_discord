defmodule BotTiago.Command.Lembrar do
  @moduledoc false

  @default_file "dados.json"

  def handle_lembrar(msg) do
    content =
      msg.content
      |> String.trim()
      |> String.replace_prefix("!lembrar", "")
      |> String.trim()

    case save_reminder(to_string(msg.author.id), content) do
      {:ok, reminder} ->
        "lembrete salvo: #{reminder["conteudo"]}"

      {:error, :empty_content} ->
        "uso: !lembrar [texto]"

      {:error, _reason} ->
        "nao consegui salvar o lembrete agora."
    end
  end

  def handle_meus_lembretes(msg) do
    user_id = to_string(msg.author.id)

    case list_reminders(user_id) do
      [] ->
        "voce ainda nao tem lembretes salvos."

      reminders ->
        formatted =
          reminders
          |> Enum.map(fn reminder ->
            "[#{reminder["data"]}] #{reminder["conteudo"]}"
          end)
          |> Enum.join(" | ")

        "seus lembretes: #{formatted}"
    end
  end

  def save_reminder(user_id, content, opts \\ []) do
    trimmed_content = String.trim(content)

    if trimmed_content == "" do
      {:error, :empty_content}
    else
      path = Keyword.get(opts, :path, @default_file)
      reminders = read_data(path)

      reminder = %{
        "usuario_id" => user_id,
        "conteudo" => trimmed_content,
        "data" => Date.utc_today() |> Date.to_iso8601()
      }

      updated =
        Map.update(reminders, "lembretes", [reminder], fn existing ->
          [reminder | existing]
        end)

      case File.write(path, Jason.encode_to_iodata!(updated, pretty: true)) do
        :ok -> {:ok, reminder}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def list_reminders(user_id, opts \\ []) do
    path = Keyword.get(opts, :path, @default_file)

    path
    |> read_data()
    |> Map.get("lembretes", [])
    |> Enum.filter(&(&1["usuario_id"] == user_id))
  end

  defp read_data(path) do
    case File.read(path) do
      {:ok, body} ->
        case Jason.decode(body) do
          {:ok, %{"lembretes" => reminders}} when is_list(reminders) ->
            %{"lembretes" => reminders}

          _ ->
            %{"lembretes" => []}
        end

      {:error, _reason} ->
        %{"lembretes" => []}
    end
  end
end
