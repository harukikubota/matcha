defmodule Matcha.Erl.Helpers do
  @spec extract_token({charlist(), integer(), any}) :: any
  def extract_token({_token, _line, value}), do: value

  @spec to_atom(charlist()) :: atom
  def to_atom(token) do
    (cond do
      # Elixir atom
      List.starts_with?(token, ':') ->
        List.delete_at(token, 0)

      # map assoc_key     ':'
      List.last(token) == 58 ->
        token = List.delete_at(token, length(token) - 1)

        # "quoted_key":
        (if List.first(token) == 34 && List.last(token) do
          Enum.slice(token, 1..-2)
        else
          token
        end)
        |> List.to_string
        |> String.to_atom

      true -> token
    end)
    |> to_string()
    |> String.to_atom
  end

  @spec to_atom(charlist(), :module) :: module()
  def to_atom(token, :module) do
    List.to_string(token)
    |> Module.concat(nil)
  end
end
