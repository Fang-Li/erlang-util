-module(lists_op).
-author("lifang").

-compile(export_all).
-export([]).


%% 实现length
length(List) when is_list(List) ->
    length(List, 0).

length([], Length) ->
    Length;
length([_ | Tail], Length) ->
    length(Tail, Length + 1).

%% 实现翻转
reverse(List) when is_list(List) ->
    reverse(List, []).

reverse([], Acc) ->
    Acc;
reverse([H | T], Acc) ->
    reverse(T, [H | Acc]).


%% 实现map

map(Fcuntion, [H | T]) when is_function(Fcuntion, 1) ->
    [Fcuntion(H) | map(Fcuntion, T)];

map(Fcuntion, []) when is_function(Fcuntion, 1) -> [].


%% 实现filter

filter(Function, List) when is_function(Function, 1) ->
    [E || E <- List, Function(E)].


foldl(F, Accu, [Hd | Tail]) ->
    foldl(F, F(Hd, Accu), Tail);
foldl(F, Accu, []) when is_function(F, 2) -> Accu.

foldr(F, Accu, [Hd | Tail]) ->
    F(Hd, foldr(F, Accu, Tail));
foldr(F, Accu, []) when is_function(F, 2) -> Accu.


append(L1, L2) -> L1 ++ L2.
append([E]) -> E;
append([H | T]) -> H ++ append(T);
append([]) -> [].

concat(List) ->
    flatmap(fun thing_to_list/1, List).

flatmap(F, [Hd | Tail]) ->
    F(Hd) ++ flatmap(F, Tail);
flatmap(F, []) when is_function(F, 1) -> [].


thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X) -> float_to_list(X);
thing_to_list(X) when is_atom(X) -> atom_to_list(X);
thing_to_list(X) when is_list(X) -> X.    %Assumed to be a string