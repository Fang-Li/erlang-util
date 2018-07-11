-module(text).
-compile(export_all).

concat(Elems) ->
  Fun = fun
    (Elem, AccIn) when is_integer(Elem) ->
      AccIn++integer_to_list(Elem);
    (Elem, AccIn) when is_binary(Elem) ->
      AccIn++binary_to_list(Elem);
    (Elem, AccIn) when is_list(Elem) ->
      AccIn++Elem;
    (Elem, AccIn) when is_atom(Elem) ->
      AccIn++atom_to_list(Elem);
    (_Elem, AccIn) ->
      AccIn 
  end,

  lists:foldr(Fun, "", lists:reverse(Elems) ). 
bin(undefined) ->
  undefined;  
bin(In) when is_binary(In) ->
  In;
bin(In) when is_list(In) ->
  list_to_binary(In);
bin(In) when is_integer(In) ->
  list_to_binary(integer_to_list(In));
bin(In) when is_atom(In) ->
  list_to_binary(atom_to_list(In));
bin(In) ->
  In.
  
str(undefined) ->
  undefined;  
str(In) when is_list(In) ->
  In;
str(In) when is_binary(In) ->
  binary_to_list(In);
str(In) when is_integer(In) ->
  integer_to_list(In);
str(In) when is_atom(In) ->
  atom_to_list(In);
str(In) ->
  In.

atom(In) when is_list(In) ->
  try
    list_to_existing_atom(In)
  catch _:_ ->
    list_to_atom(In)
  end;
atom(In) when is_binary(In) ->
  atom(binary_to_list(In) );
atom(In) when is_atom(In) ->
  In.

integer(In) when is_list(In) ->
  list_to_integer(In);
integer(In) when is_binary(In) ->
  binary_to_integer(In);
integer(In) when is_integer(In) ->
  In.

bin_batch(L) ->
  Fun = fun(In) ->
    bin(In)
  end,
  lists:map(Fun, L).

str_batch(L) ->
  Fun = fun(In) ->
    str(In)
  end,
  lists:map(Fun, L).

tokens(undefined, _SeparatorList) ->
  [];
tokens(String, SeparatorList) when is_list(String) ->
  string:tokens(String, SeparatorList);
tokens(Binary, SeparatorList) when is_binary(Binary) ->
  string:tokens(binary_to_list(Binary), SeparatorList);
tokens(In, _SeparatorList) ->
  In.

join(List, Separator) ->
  StringList = lists:map(fun str/1, List),
  string:join(StringList, Separator).

format(Format, Args) ->
  lists:flatten( io_lib:format(Format, Args) ).

digest(StringList, Separator) ->
  Hash = crypto:hash(md5,text:join(StringList, Separator) ),
  mochihex:to_hex(Hash).

tail(In, SeparatorList) when is_binary(In) ->
  tail(str(In), SeparatorList);
tail(String, SeparatorList) ->
  Tokens = string:tokens(String, SeparatorList),
  Length = length(Tokens),
  case Length of
    0 -> [];
    _ -> lists:nth(Length, Tokens)
  end.
