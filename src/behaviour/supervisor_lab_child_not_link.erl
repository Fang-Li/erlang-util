%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(supervisor_lab_child_not_link).

-compile(export_all).


start_link() ->
    P = spawn(fun() -> loop() end),
    register(child_not_link, P),
    {ok, self()}.



loop() ->
    receive
        A ->
            io:format("~p~n", [A]),
            loop()
    end.



