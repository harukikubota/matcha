Definitions.

D       = [0-9]+
S       = [a-zA-Z0-9_]*
ATOM_TAIL = (\?|\!)?
ATOM_BODY = [a-zA-Z_]{S}{ATOM_TAIL}

INT     = \-?{D}
FLOAT   = \-?{D}\.{D}
STRING  = "[^"\\]*(.[^"\\]*)*"
CHAR    = '[^'\\]*(\\.[^'\\]*)*'

ATOM = ((true|false|nil)|:{ATOM_BODY}|:{STRING})
MODULE  = [A-Z]{S}(\.[A-Z]{S})*

VARIABLE  = [a-z]{S}{ATOM_TAIL}
UNUSE_VAR = _({VARIABLE})?

ASSOC_KEY_SYMBOL = {VARIABLE}:
ASSOC_KEY_STRING = {STRING}:

WHITESPACE = [\s\t\n\r]

Rules.

% val
{INT}    : {token, {integer,  TokenLine, list_to_integer(TokenChars)}}.
{FLOAT}  : {token, {float,    TokenLine, list_to_float(TokenChars)}}.
{STRING} : {token, {string,   TokenLine, to_string(TokenChars)}}.
{CHAR}   : {token, {charlist, TokenLine, to_charlist(TokenChars)}}.

% atom
{ATOM}    : {token, {atom,   TokenLine, to_atom(TokenChars)}}.
{MODULE}  : {token, {module, TokenLine, to_atom(TokenChars, module)}}.

% var
{VARIABLE}  : {token, {var,       TokenLine, to_atom(TokenChars)}}.
{UNUSE_VAR} : {token, {unuse_var, TokenLine, to_atom(TokenChars)}}.

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
\*\* : {token, {'**', TokenLine}}.
\*  : {token, {'*',  TokenLine}}.

%% data_structure modifier.
%% map
\%   : {token, {'%', TokenLine}}.
%% range
\.   : {token, {'.', TokenLine}}.
\.\. : {token, {'..', TokenLine}}.

%% map assoc_key
{ASSOC_KEY_SYMBOL}|{ASSOC_KEY_STRING} : {token, {assoc_key, TokenLine, to_atom(TokenChars)}}.

{WHITESPACE}+ : skip_token.

Erlang code.

to_atom(TokenChars) -> 'Elixir.Matcha.Erl.Helpers':to_atom(TokenChars).
to_atom(TokenChars, Atom) -> 'Elixir.Matcha.Erl.Helpers':to_atom(TokenChars, Atom).

to_string(Token) -> 'Elixir.Matcha.Erl.Helpers':to_binary(Token).

to_charlist(Token) ->'Elixir.Matcha.Erl.Helpers':to_charlist(Token).
