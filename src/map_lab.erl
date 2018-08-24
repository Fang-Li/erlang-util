-module(map_lab).
-compile(export_all).

pattern(#{type := a, num := b}) ->
	a.

get(A) ->
	case A of
		#{type :=a} -> a;
		#{num := b} -> b;
		_ -> c
	end. 
