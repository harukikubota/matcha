defmodule MatchaParserSpec do
  use ESpec

  before do: {
    :shared,
    parse: (fn s ->
      {:ok, tokens, _} = to_charlist(s) |> :matcha_tokenizer.string(s)
      {:ok, ast} = :matcha_parser.parse(tokens)
      ast
    end)
  }

  describe "variable" do
    context "use_var" do
      subject do: shared.parse.("var_name")
      it do: is_expected() |> to(match_pattern {:var, :var_name})
    end

    context "^var" do
      subject do: shared.parse.("^name")

      it do: is_expected() |> to(match_pattern {:^, :name})
    end

    context "unuse_var" do
      subject do: shared.parse.("_var_name")
      it do: is_expected() |> to(match_pattern {:unuse_var, :_var_name})
    end
  end

  describe "value" do
    context "ok" do
      let :integer,  do: shared.parse.("1234567890")
      let :float,    do: shared.parse.("3.14")
      let :charlist, do: shared.parse.("'character'")
      let :string,   do: shared.parse.('"string"')
      let :atom,     do: shared.parse.(":atom")
      let :q_atom,   do: shared.parse.(':"quoted-atom"')
      let :v_true,   do: shared.parse.("true")
      let :v_false,  do: shared.parse.("false")
      let :v_nil,    do: shared.parse.("nil")
      let :module_a, do: shared.parse.("String")
      let :module_b, do: shared.parse.("String.Chars")

      it do: expect integer()  |> to(match_pattern {:val, 1234567890})
      it do: expect float()    |> to(match_pattern {:val, 3.14})
      it do: expect charlist() |> to(match_pattern {:val, 'character'})
      it do: expect string()   |> to(match_pattern {:val, "string"})
      it do: expect atom()     |> to(match_pattern {:val, :atom})
      it do: expect q_atom()   |> to(match_pattern {:val, :"quoted-atom"})
      it do: expect v_true()   |> to(match_pattern {:val, true})
      it do: expect v_false()  |> to(match_pattern {:val, false})
      it do: expect v_nil()    |> to(match_pattern {:val, nil})
      it do: expect module_a() |> to(match_pattern {:val, String})
      it do: expect module_b() |> to(match_pattern {:val, String.Chars})
    end

    context "edge_case charlist" do
      # charlistが複数含まれている場合、1つのリテラルとして結合されてしまう
      let :double_char, do: shared.parse.("['hoge', 'fuga']")

      it do: expect double_char() |> to(match_pattern {:"[]", [vl: {:val, 'hoge'}, vl: {:val, 'fuga'}]})
    end
  end

  describe "deta_structure" do
    context "Tuple" do
      let :tuple_zero, do: shared.parse.("{}")
      let :tuple_one , do: shared.parse.("{:one}")
      let :tuple_many, do: shared.parse.("{:ok, :error}")

      it do: expect tuple_zero() |> to(match_pattern {:{}, []})
      it do: expect tuple_one()  |> to(match_pattern {:{}, [vl: {:val, :one}]})
      it do: expect tuple_many() |> to(match_pattern {:{}, [vl: {:val, :ok}, vl: {:val, :error}]})
    end

    context "List, not a Keyword" do
      let :list_zero, do: shared.parse.("[]")
      let :list_one , do: shared.parse.("[1]")
      let :list_many, do: shared.parse.('[1, :ok, "name"]')

      it do: expect list_zero() |> to(match_pattern {:"[]", []})
      it do: expect list_one()  |> to(match_pattern {:"[]", [vl: {:val, 1}]})
      it do: expect list_many() |> to(match_pattern {:"[]", [vl: {:val, 1}, vl: {:val, :ok}, vl: {:val, "name"}]})
    end

    context "partial Keyword" do
      let :keyword_one ,    do: shared.parse.("[one: 1]")
      let :keyword_many,    do: shared.parse.("[one: 1, two: \"tow\", three: 3.0]")
      let :include_keyword, do: shared.parse.("[one: 1, :ok]")

      it do: expect keyword_one()     |> to(match_pattern {:"[]", [as: {:one, {:val, 1}}]})
      it do: expect keyword_many()    |> to(match_pattern {:"[]", [as: {:one, {:val, 1}}, as: {:two, {:val, "tow"}}, as: {:three, {:val, 3.0}}]})
      it do: expect include_keyword() |> to(match_pattern {:"[]", [as: {:one, {:val, 1}}, vl: {:val, :ok}]})
    end

    context "Range" do
      let :num_num, do: shared.parse.("-100..100")
      let :num_var, do: shared.parse.("-100..one")
      let :var_num, do: shared.parse.("one..10")
      let :var_var, do: shared.parse.("one..ten")

      it do: expect num_num() |> to(match_pattern {:.., [val: -100, val: 100]})
      it do: expect num_var() |> to(match_pattern {:.., [val: -100, var: :one]})
      it do: expect var_num() |> to(match_pattern {:.., [var: :one, val: 10]})
      it do: expect var_var() |> to(match_pattern {:.., [var: :one, var: :ten]})
    end

    context "Map" do
      let :map_empty, do: shared.parse.("%{}")
      let :map_one,   do: shared.parse.("%{key: :val}")
      let :map_many,  do: shared.parse.("%{key: :val, hoge: :fuga}")
      let :map_key_is_not_an_atom, do: shared.parse.('%{"key" => :val, 1 => 1.0}')

      it do: expect map_empty() |> to(match_pattern {:%{}, []})
      it do: expect map_one()   |> to(match_pattern {:%{}, [as: {:key, {:val, :val}}]})
      it do: expect map_many()  |> to(match_pattern {:%{}, [as: {:key, {:val, :val}}, as: {:hoge, {:val, :fuga}}]})
      it do: expect map_key_is_not_an_atom() |> to(match_pattern {:%{}, [as: {"key", {:val, :val}}, as: {1, {:val, 1.0}}]})
    end

    context "Struct" do
      let :struct_empty,       do: shared.parse.("%Hoge{}")
      let :struct_capture_mod, do: shared.parse.("%name{}")
      let :struct_inject_mod,  do: shared.parse.("%^name{}")
      let :struct_one,         do: shared.parse.("%Hoge{key: :val}")
      let :struct_many,        do: shared.parse.("%Hoge.Struct{key: :val, hoge: :fuga}")

      it do: expect struct_empty()       |> to(match_pattern {:"%_{}", [name: Hoge]})
      it do: expect struct_capture_mod() |> to(match_pattern {:"%_{}", [capture: :name]})
      it do: expect struct_inject_mod()  |> to(match_pattern {:"%_{}", [inject: :name]})
      it do: expect struct_one()         |> to(match_pattern {:"%_{}", [name: Hoge, as: {:key, {:val, :val}}]})
      it do: expect struct_many()        |> to(match_pattern {:"%_{}", [name: Hoge.Struct, as: {:key, {:val, :val}}, as: {:hoge, {:val, :fuga}}]})
    end

    context "Record" do
      let :record_local_context, do: shared.parse.("record()")
      let :record_with_module,   do: shared.parse.("Hoge.record()")

      it do: expect record_local_context() |> to(match_pattern {:"#_{}", [:record]})
      it do: expect record_with_module()   |> to(match_pattern {:"#_{}", [{:., [Hoge, :record]}]})
    end
  end

  describe "match" do
    context "val" do
      subject do: shared.parse.("name = :name")

      it do: is_expected() |> to(match_pattern {:=, {:name, {:val, :name}}})
    end

    context "var" do
      subject do: shared.parse.("name_1 = name_2")

      it do: is_expected() |> to(match_pattern {:=, {:name_1, {:var, :name_2}}})
    end

    context "data_structure" do
      subject do: shared.parse.("map = %{name: name, address:}")

      it do: is_expected() |> to(match_pattern {:=,
      {:map, {:%{}, [as: {:name, {:var, :name}}, as: {:address, {:var, :address}}]}}})
    end
  end

  describe "*(collect other attributes)" do
    context "for List" do
      # in_example [1, 2, 3, 4, 5]
      let :exp_bind,  do: shared.parse.("[*other, four , five]")
      let :exp_match, do: shared.parse.("[one   , two  , *[3, 4, 5]]")

      it do: expect exp_bind()  |> to(match_pattern {:"[]", [vl: {:*, {:var, :other}}, vl: {:var, :four}, vl: {:var, :five}]})
      it do: expect exp_match()   |> to(match_pattern {:"[]", [vl: {:var, :one}, vl: {:var, :two}, vl: {:*, {:"[]", [vl: {:val, 3}, vl: {:val, 4}, vl: {:val, 5}]}}]})
    end

    context "for Map" do
      let :bind_var, do: shared.parse.("%{name: name, *other}")
      let :match,    do: shared.parse.("%{name: name, *[age: 18]}")

      it do: expect bind_var() |> to(match_pattern {:%{}, [as: {:name, {:var, :name}}, vl: {:*, {:var, :other}}]})
      it do: expect match()    |> to(match_pattern {:%{}, [as: {:name, {:var, :name}}, vl: {:*, {:"[]", [as: {:age, {:val, 18}}]}}]})
    end
  end
end
