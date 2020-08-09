defmodule GymRats.NumberFormatter do
  def format_score(score, challenge) do
    case challenge.score_by do
      "distance" -> :erlang.float_to_binary(score, decimals: 1) |> format()
      _ -> round(score) |> format()
    end
  end

  def format(number) when is_binary(number) do
    format(String.to_float(number))
  end

  def format(number) when is_integer(number) do
    number
    |> Integer.to_char_list()
    |> Enum.reverse()
    |> Enum.chunk_every(3, 3, [])
    |> Enum.join(",")
    |> String.reverse()
  end

  def format(number) when is_float(number) do
    number
    |> to_string
    |> String.replace(~r/\d+(?=\.)|\A\d+\z/, fn int ->
      int
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.chunk_every(3, 3, [])
      |> Enum.join(",")
      |> String.reverse()
    end)
  end
end
