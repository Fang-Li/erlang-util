-module(fun_lab).
-compile(export_all).

fun_lab(Num) ->
	Fun = fun(0) -> a;
          (_Num) -> b 
          end,
	Fun(Num).

lab(A,[A]) ->
  A;
lab(A,B) ->
  bbb.

lab2(A,B,B=C) ->
  C;
lab2(A,B,C)->
  aaa.

guard([A1,A1|A]) ->
	a;
guard([A1,A2|A]) when A1 == A2 ->
    b;
guard(_) ->
	c. 

-record(a,{b=#{}}).
map(#a{b=#{}}) ->
	a;
map(_) ->
	b.
