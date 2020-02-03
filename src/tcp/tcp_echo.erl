%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% tcp请求响应
%%% @end
%%%-------------------------------------------------------------------
-module(tcp_echo).
-compile(export_all).

start() ->
    start(1234).

start(Port) ->
    {ok, Listener} = gen_tcp:listen(Port, [binary, {active, false}, {reuseaddr, true}]),
    accept(Listener).

accept(Listener) ->
    {ok, CSock} = gen_tcp:accept(Listener),
    loop(CSock).

loop(CSock) ->
    inet:setopts(CSock, [{active, once}]),
    receive
        {tcp, CSock, Message} ->
            io:format("receive .. ~p~n", [Message]),
            gen_tcp:send(CSock, Message),
            loop(CSock)
    end.