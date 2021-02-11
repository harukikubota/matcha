defmodule Matcha.TokenizerSpec do
  use ESpec

  describe "variable" do
    context "simple_name" do
      subject :matcha_tokenizer.string('var_Name1')
      it do: is_expected() |> to(match_pattern {:ok, [{:var, 1, :var_Name1}], 1})
    end

    context "end with '?'" do
      subject :matcha_tokenizer.string('var?')
      it do: is_expected() |> to(match_pattern {:ok, [{:var, 1, :var?}], 1})
    end

    context "end with '!'" do
      subject :matcha_tokenizer.string('var!')
      it do: is_expected() |> to(match_pattern {:ok, [{:var, 1, :var!}], 1})
    end

    context "unuse_var only '_'" do
      subject :matcha_tokenizer.string('_')
      it do: is_expected() |> to(match_pattern {:ok, [{:unuse_var, 1, :_}], 1})
    end

    context "unuse_var" do
      subject :matcha_tokenizer.string('_unuse')
      it do: is_expected() |> to(match_pattern {:ok, [{:unuse_var, 1, :_unuse}], 1})
    end
  end

  describe "value" do
    context "positive integer" do
      subject :matcha_tokenizer.string('1234598760')
      it do: is_expected() |> to(match_pattern {:ok, [{:integer, 1, 1234598760}], 1})
    end

    context "negative integer" do
      subject :matcha_tokenizer.string('-10')
      it do: is_expected() |> to(match_pattern {:ok, [{:integer, 1, -10}], 1})
    end

    context "positive float" do
      subject :matcha_tokenizer.string('3.14')
      it do: is_expected() |> to(match_pattern {:ok, [{:float, 1, 3.14}], 1})
    end

    context "negative float" do
      subject :matcha_tokenizer.string('-1.4142')
      it do: is_expected() |> to(match_pattern {:ok, [{:float, 1, -1.4142}], 1})
    end

    context "string" do
      subject :matcha_tokenizer.string('"hoge"')
      it do: is_expected() |> to(match_pattern {:ok, [{:string, 1, "hoge"}], 1})
    end

    context "string with meta" do
      subject :matcha_tokenizer.string('"\"\'hoge\n\t\r"')
      it do: is_expected() |> to(match_pattern {:ok, [{:string, 1, "\"'hoge\n\t\r"}], _})
    end

    context "charlist" do
      subject :matcha_tokenizer.string('\'character_list\'')
      it do: is_expected() |> to(match_pattern {:ok, [{:charlist, 1, 'character_list'}], 1})
    end

    context "atom(symbol)" do
      subject :matcha_tokenizer.string(':symbol')
      it do: is_expected() |> to(match_pattern {:ok, [{:atom, 1, :symbol}], 1})
    end

    context "module not including dot" do
      subject :matcha_tokenizer.string('String')
      it do: is_expected() |> to(match_pattern {:ok, [{:module, 1, String}], 1})
    end

    context "module including dot" do
      subject :matcha_tokenizer.string('String.Chars')
      it do: is_expected() |> to(match_pattern {:ok, [{:module, 1, String.Chars}], 1})
    end
  end

  describe "brakets" do
    context "ok" do
      let :lparen,  do: :matcha_tokenizer.string('(')
      let :rparen,  do: :matcha_tokenizer.string(')')
      let :lbraket, do: :matcha_tokenizer.string('[')
      let :rbraket, do: :matcha_tokenizer.string(']')
      let :lbrace,  do: :matcha_tokenizer.string('{')
      let :rbrace,  do: :matcha_tokenizer.string('}')
      let :langel,  do: :matcha_tokenizer.string('<')
      let :rangel,  do: :matcha_tokenizer.string('>')

      it do: expect lparen()  |> to(match_pattern {:ok, ["(": 1], 1})
      it do: expect rparen()  |> to(match_pattern {:ok, [")": 1], 1})
      it do: expect lbraket() |> to(match_pattern {:ok, ["[": 1], 1})
      it do: expect rbraket() |> to(match_pattern {:ok, ["]": 1], 1})
      it do: expect lbrace()  |> to(match_pattern {:ok, ["{": 1], 1})
      it do: expect rbrace()  |> to(match_pattern {:ok, ["}": 1], 1})
      it do: expect langel()  |> to(match_pattern {:ok, ["<": 1], 1})
      it do: expect rangel()  |> to(match_pattern {:ok, [">": 1], 1})
    end
  end

  describe "separator" do
    context "ok" do
      let :pipe,           do: :matcha_tokenizer.string('|')
      let :comma,          do: :matcha_tokenizer.string(',')
      let :assoc_delimita, do: :matcha_tokenizer.string('=>')

      it do: expect pipe()           |> to(match_pattern {:ok, ["|": 1], 1})
      it do: expect comma()          |> to(match_pattern {:ok, [",": 1], 1})
      it do: expect assoc_delimita() |> to(match_pattern {:ok, ["=>": 1], 1})
    end
  end

  describe "operators" do
    context "ok" do
      let :match, do: :matcha_tokenizer.string('=')

      it do: expect match() |> to(match_pattern {:ok, ["=": 1], 1})
    end
  end

  describe "data_structure modifier" do
    let :percent, do: :matcha_tokenizer.string('%')
    let :two_dot, do: :matcha_tokenizer.string('..')

    it do: expect percent() |> to(match_pattern {:ok, ["%": 1], 1})
    it do: expect two_dot() |> to(match_pattern {:ok, ["..": 1], 1})
  end

  describe "assoc_key" do
    let :quoted_key, do: :matcha_tokenizer.string('"quoted-key":')
    let :symbol_key, do: :matcha_tokenizer.string('key:')

    it do: expect quoted_key() |> to(match_pattern {:ok, [{:assoc_key, 1, :"quoted-key"}], 1})
    it do: expect symbol_key() |> to(match_pattern {:ok, [{:assoc_key, 1, :key}], 1})
  end
end
