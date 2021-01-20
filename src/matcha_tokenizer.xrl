Definitions.

INT       = [0-9]+
STRING    = "(\n|.)*"
ATOM      = :[a-zA-Z0-9_]*(\?|\!)?
MODULE    = [A-Z][A-Za-z0-9]*(\.[A-Z][A-Za-z0-9]*)*

VARIABLE  = [a-z][a-zA-Z0-9_]*(\?|\!)?
UNUSE_VAR = _({VARIABLE})?

ASSOC_KEY_SYMBOL = {VARIABLE}:
ASSOC_KEY_STRING = {STRING}:

WHITESPACE = [\s\t\n\r]

Rules.

{INT}       : {token, {integer,   TokenLine, list_to_integer(TokenChars)}}.
{STRING}    : {token, {string,    TokenLine, to_string(TokenChars)}}.
{ATOM}      : {token, {atom,      TokenLine, to_atom(TokenChars)}}.
{VARIABLE}  : {token, {variable,  TokenLine, to_atom(TokenChars)}}.
{UNUSE_VAR} : {token, {unuse_var, TokenLine}}.
{MODULE}    : {token, {module,    TokenLine, to_atom(TokenChars, module)}}.

%% separators.
,  : {token, {',', TokenLine}}.
\| : {token, {'|', TokenLine}}.
=> : {token, {'=>', TokenLine}}.

%% brakets.
\( : {token, {'(', TokenLine}}.
\) : {token, {')', TokenLine}}.
\[ : {token, {'[', TokenLine}}.
\] : {token, {']', TokenLine}}.
\{ : {token, {'{', TokenLine}}.
\} : {token, {'}', TokenLine}}.
<  : {token, {'<', TokenLine}}.
>  : {token, {'>', TokenLine}}.

%% operators.
=  : {token, {'=', TokenLine}}.

%% prefix modifier.
\^  : {token, {'^',  TokenLine}}.
\** : {token, {'**', TokenLine}}.
\*  : {token, {'=',  TokenLine}}.

%% data_structure modifier.
%% map
\%   : {token, {'%', TokenLine}}.
%% range
\.\. : {token, {'..', TokenLine}}.

%% map assoc_key
{ASSOC_KEY_SYMBOL} : {token, {assoc_key,        TokenLine, to_atom(TokenChars)}}.
{ASSOC_KEY_STRING} : {token, {quoted_assoc_key, TokenLine, to_atom(TokenChars)}}.

{WHITESPACE}+ : skip_token.

Erlang code.

to_atom(TokenChars) -> 'Elixir.Matcha.Erl.Helpers':to_atom(TokenChars).
to_atom(TokenChars, Atom) -> 'Elixir.Matcha.Erl.Helpers':to_atom(TokenChars, Atom).

to_string(Token) ->
  S = lists:sublist(Token, 2, length(Token) - 2),
  case catch list_to_atom(gen_string(S)) of
    {'EXIT',_} -> {error,"illegal atom " ++ Token};
    String -> atom_to_binary(String)
  end.

gen_string([C|Cs]) ->
    [C|gen_string(Cs)];
gen_string([]) -> [].
