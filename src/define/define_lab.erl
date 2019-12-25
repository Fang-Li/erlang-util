%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(define_lab).

-compile(export_all).

%% 宏参数字符串化(Stringifying Macro Arguments)
-define(TESTCALL(Call), io:format("Call ~s: ~w~n", [??Call, Call])).


test() ->
    ?TESTCALL(myfunction(1, 2)),
    A = a, B = 123,
    ?TESTCALL(myfunction(A, B)).

myfunction(_, _) -> ok.

%%io:format("Call ~s: ~w~n",["myfunction ( 1 , 2 )",myfunction(1,2)]),
%%io:format("Call ~s: ~w~n",["you : function ( 2 , 1 )",you:function(2,1)]).
