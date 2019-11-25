%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(supervisor_lab_child).

-compile(export_all).


start_link() ->
    P = spawn(fun() -> loop() end),
    register(child, P),
    link(P),
    {ok, P}.



loop() ->
    receive
        A ->
            io:format("~p~n", [A]),
            loop()
    end.



