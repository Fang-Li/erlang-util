%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% tcp请求响应 async_accept
%%% @end
%%%-------------------------------------------------------------------
-module(tcp_echo2).
-compile(export_all).

start() ->
    start(1234).

start(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [binary, {active, false}, {reuseaddr, true}]),
    spawn(fun() -> handle(LSock) end).

handle(LSock) ->
    {ok, Ref} = prim_inet:async_accept(LSock, -1),
    loop(LSock, Ref).

loop(LSock, Ref) ->
    receive
        {inet_async, LSock, Ref, {ok, CSock}} ->
            set_sockopt(LSock, CSock),
            CHandle = spawn(fun() -> client(CSock) end),
            gen_tcp:controlling_process(CSock, CHandle),
            {ok, NewRef} = prim_inet:async_accept(LSock, -1),
            loop(LSock, NewRef);
        Recv ->
            io:format("receive .. ~p~n", [Recv]),
            loop(LSock, Ref)
    end.


client(CSock) ->
    inet:setopts(CSock, [{active, once}]),
    client_loop(CSock).

client_loop(CSock) ->
    receive
        {tcp, CSock, Message} ->
            inet:setopts(CSock, [{active, once}]),
            io:format("~p got message ~p\n", [self(), Message]),
            gen_tcp:send(CSock, <<"Echo back : ", Message/binary>>),
            client_loop(CSock);
        Recv ->
            io:format("receive .. ~p~n", [Recv]),
            client_loop(CSock)
    end.

set_sockopt(LSock, CliSocket) ->
    true = inet_db:register_socket(CliSocket, inet_tcp),
    case prim_inet:getopts(LSock, [active, nodelay, keepalive, delay_send, priority, tos]) of
        {ok, Opts} ->
            case prim_inet:setopts(CliSocket, Opts) of
                ok -> ok;
                Error -> gen_tcp:close(CliSocket), Error
            end;
        Error ->
            gen_tcp:close(CliSocket), Error
    end.