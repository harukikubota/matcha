defmodule Matcha.Erl.Helpers do
  @moduledoc """
  This module defines helper functions for the parsing tool.
  """
  @typep ast() :: {atom(), term()}

  @spec extract_token({charlist(), integer(), any}) :: any
  def extract_token({_token, _line, value}), do: value

  @spec to_atom(charlist()) :: atom()
  def to_atom(token) do
    trim_colon(token)
    |> trim_double_quote_if_quoted()
    |> to_string()
    |> String.to_atom
  end

  @spec to_atom(charlist(), :module) :: module()
  def to_atom(token, :module) do
    List.to_string(token)
    |> Module.concat(nil)
  end

  @spec to_binary(charlist()) :: binary()
  def to_binary(token) do
    trim_quote(token)
    |> :elixir_utils.characters_to_binary()
  end

  @spec to_charlist(charlist()) :: charlist()
  def to_charlist(token), do: trim_quote(token)

  @spec validate_range(ast(), ast()) :: [ast()]
  def validate_range(left, right) do
    error_mes =
      [left, right]
      |> Enum.reject(fn {token, val} ->
        case token do
          :var -> true
          :val -> is_integer(val)
        end
      end)
      |> Enum.map(&("range can't specified #{inspect(&1)}."))
      |> Enum.join("\n")

    unless error_mes == "" do
      raise error_mes
    else
      [left, right]
    end
  end

  defp trim_colon(':' ++ char), do: char
  defp trim_colon(token) do
    if List.last(token) == ?: do
      List.delete_at(token, length(token) - 1)
    else
      token
    end
  end

  # '\'character\'' -> 'character'
  defp trim_quote(token), do: Enum.slice(token, 1..-2)

  defp trim_double_quote_if_quoted(token) do
    if List.first(token) == ?"
    && List.last(token)  == ?"
    do
      trim_quote(token)
    else
      token
    end
  end
end
