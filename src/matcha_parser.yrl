Nonterminals grammer
  expr variable value data_structure
  exprs exprs_block assoc record_name module_name.

Terminals
  % var OK
  var unuse_var
  % val
  integer float charlist string atom module
  % data_structure_attributes
  assoc_key
  % symbol
  '^' '*' '%'
  % parens
  '[' ']' '(' ')' '{' '}' %'<' '>'
  % delimitor
  '.' ',' '..' '=>' '='.

Rootsymbol grammer.

Left 50 expr.
Left 55 assoc_key.

grammer -> expr : '$1'.

% TODO エクストラクターに対応したい
expr -> '*' expr       : {'*', '$2'}.
expr -> var '=' expr   : {'=', {token('$1'), '$3'}}.
expr -> variable       : '$1'.
expr -> value          : {val, '$1'}.
expr -> data_structure : '$1'.

variable -> var       : {var, token('$1')}.
variable -> '^' var   : {'^', token('$2')}.
variable -> unuse_var : {unuse_var, token('$1')}.

value -> integer  : token('$1').
value -> float    : token('$1').
value -> charlist : token('$1').
value -> string   : token('$1').
value -> atom     : token('$1').
value -> module   : token('$1').

% Tuple
data_structure -> '{' '}'       : {'{}', []}.
data_structure -> '{' exprs '}' : {'{}', '$2'}.

% List
data_structure -> '[' ']'       : {'[]', []}.
data_structure -> '[' exprs ']' : {'[]', '$2'}.

% Range
data_structure -> expr '..' expr : {'..', validate_range('$1', '$3')}.

% Map
data_structure -> '%' '{' '}'       : {'%{}', []}.
data_structure -> '%' '{' exprs '}' : {'%{}', '$3'}.

% Struct
data_structure -> '%' module_name '{' '}'       : {'%_{}', ['$2']}.
data_structure -> '%' module_name '{' exprs '}' : {'%_{}', ['$2' | '$4']}.

% Record
data_structure -> record_name '(' ')'       : {'#_{}', ['$1']}.
data_structure -> record_name '(' exprs ')' : {'#_{}', ['$1' | '$3']}.

exprs -> exprs_block           : ['$1'].
exprs -> exprs_block ',' exprs : ['$1' | '$3'].

%% 各値が式かキーワードなのかを判別するために設定する
exprs_block -> expr  : {vl, '$1'}.
exprs_block -> assoc : {as, '$1'}.

% short_syntax `[ok:] -> [ok: ok]`
assoc -> assoc_key      : {token('$1'), {var, token('$1')}}.
assoc -> assoc_key expr : {token('$1'), '$2'}.
assoc -> expr '=>' expr : {element(2, '$1'), '$3'}.

module_name -> module  : {name, token('$1')}.
module_name -> '^' var : {inject, token('$2')}.
module_name -> var     : {capture, token('$1')}.

record_name -> var : token('$1').
record_name -> module '.' var : {'.', [token('$1'), token('$3')]}.

Erlang code.

token(Token) ->
  'Elixir.Matcha.Erl.Helpers':extract_token(Token).

validate_range(Left, Right) ->
  'Elixir.Matcha.Erl.Helpers':validate_range(Left, Right).