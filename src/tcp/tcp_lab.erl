%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% tcp请求响应
%%% prim_inet:async_accept 流程测试
%%% @end
%%%-------------------------------------------------------------------
-module(tcp_lab).
-compile(export_all).

start() ->
    start(1234).

start(Port) ->
    {ok, AcceptSocket} = gen_tcp:listen(Port, [binary, {active, false}]),
    listen(AcceptSocket).

listen(Socket) ->
    {ok, Connection} = gen_tcp:accept(Socket),
    accept(Connection).

accept(Connection) ->
    receive
        {tcp, _ClientSocket, Message} ->
            io:format("receive .. ~p~n", [Message]),
            accept(Connection);
        {send, Message} ->
            io:format("receive .. ~p~n", [Message]),
            gen_tcp:send(Connection, Message),
            accept(Connection);
        Recv ->
            io:format("receive .. ~p~n", [Recv]),
            accept(Connection)
    end.