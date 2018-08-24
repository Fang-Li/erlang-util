-module(fun_lab).
-compile(export_all).

fun_lab(Num) ->
	Fun = fun(0) -> a;
          (_Num) -> b 
          end,
	Fun(Num).
