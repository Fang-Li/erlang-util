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
    {ok, Socket} = gen_tcp:accept(Listener),
    loop(Socket).

loop(Connection) ->
    inet:setopts(Connection, [{active, once}]),
    receive
        {tcp, Connection, Message} ->
            io:format("receive .. ~p~n", [Message]),
            gen_tcp:send(Connection, Message),
            loop(Connection)
    end.