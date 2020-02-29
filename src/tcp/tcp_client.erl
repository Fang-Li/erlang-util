%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 客户端
%%% @end
%%%-------------------------------------------------------------------
-module(tcp_client).

-compile(export_all).

connect() ->
    connect(1234).

connect(Port) ->
    {ok, Socket} = gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 0}]),
    erlang:put(socket, Socket),
    Socket.

call() ->
    call(erlang:get(socket)).

call(Socket) ->
    send_data(Socket),
    receive_data(Socket).

send_data(Socket) ->
    ok = gen_tcp:send(Socket, "aaa\r\n").

receive_data(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("client receive ~p .. ~p~n", [Socket, Bin]);
        {tcp_closed, Socket} ->
            io:format("server socket closed .. ~p~n", [Socket])
    end.