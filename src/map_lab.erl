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

%% ====测试 fun 函数用普通函数代替

%% fun_test(_Key,Value,Acc) ->
%% 	[Value|Acc].
%%  
%% map_test() ->
%% 	Fun = fun fun_test/3,
%% 	maps:fold(Fun(Key,Value,Acc) ,[],#{1=>1,2=>2}).

match() ->
    do_match(#{a=>a, b=>b}).
%do_match(#{a:=Key=a}) ->
%	Key;
do_match(#{a:=a = Key}) ->
    Key;
do_match(#{}) ->
    else.
