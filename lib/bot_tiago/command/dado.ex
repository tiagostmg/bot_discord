defmodule BotTiago.Command.Dado do
  @moduledoc false

  def handle_dado(msg) do
    case String.split(msg.content, ~r/\s+/, trim: true) do
      ["!dado", quantity, sides] -> execute(quantity, sides)
      _ -> "uso: !dado [quantidade] [lados]"
    end
  end

  def execute(quantity, sides) do
    with {:ok, parsed_quantity} <- parse_integer(quantity),
         {:ok, parsed_sides} <- parse_integer(sides),
         :ok <- validate(parsed_quantity, parsed_sides) do
      rolls = for _ <- 1..parsed_quantity, do: Enum.random(1..parsed_sides)
      total = Enum.sum(rolls)
      "resultado: #{Enum.join(Enum.map(rolls, &Integer.to_string/1), ", ")} | total: #{total}"
    else
      {:error, :invalid_integer} -> "quantidade e lados precisam ser inteiros. exemplo: !dado 2 20"
      {:error, :invalid_range} -> "use quantidade entre 1 e 20 e lados entre 2 e 1000."
    end
  end

  defp parse_integer(value) do
    case Integer.parse(value) do
      {number, ""} -> {:ok, number}
      _ -> {:error, :invalid_integer}
    end
  end

  defp validate(quantity, sides) when quantity in 1..20 and sides in 2..1000, do: :ok
  defp validate(_, _), do: {:error, :invalid_range}
end
