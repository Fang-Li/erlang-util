-module(broadcast).
-export([start/1]).
-export([start/0]).

%%--------------------------------------------------------------------
%% @private
%% @doc
%%
%% 监听端口
%% 消息广播给所有连接
%%
%% @end
%%--------------------------------------------------------------------

start() ->
  start(1234).

start(Port) ->
  {ok, AcceptSocket} = gen_tcp:listen(Port, [binary, {active, false}]),
  io:fwrite("Now listening for new connections"),

  % Process managing client connections
  ManagerId = spawn(fun() -> manage_clients([]) end),

  % Process accepting new connections
  spawn(fun() -> listen(AcceptSocket, ManagerId) end).

listen(Socket, ManagerId) ->
  {ok, Connection} = gen_tcp:accept(Socket),

  ClientPid = spawn(fun() -> handle(Connection, ManagerId) end),

  gen_tcp:controlling_process(Connection, ClientPid),
  ManagerId ! {newClient, ClientPid}, % notify manager of new client
  listen(Socket, ManagerId).

handle(Socket, ManagerId) ->

  % Switch to active mode for a single message
  inet:setopts(Socket, [{active, once}]),

  receive
    {tcp, Socket, <<"quit", _/binary>>} ->
      io:format("receive .. ~p~n",[<<"quit">>]),
      gen_tcp:close(Socket);
    {tcp, Socket, Message} ->
      io:format("receive .. ~p~n",[Message]),
      ManagerId ! {broadcast, Message, self()}, % instruct manager process to broadcast message to clients
      handle(Socket, ManagerId);
    {send, Message} ->
      io:format("receive .. ~p~n",[Message]),
      gen_tcp:send(Socket, Message),
      handle(Socket, ManagerId)
  end.

% broadcast message to all clients
send_to_clients(Message, Clients) ->
  lists:foreach(fun(ClientPid) -> ClientPid ! {send,Message} end, Clients).

manage_clients(Clients) ->
  receive
    {newClient, Client} ->
      io:fwrite("Accepted new connection~n"),
      manage_clients([Client | Clients]);
    {broadcast, Message, _} ->
      send_to_clients(Message, Clients),
      manage_clients(Clients)
  end.
