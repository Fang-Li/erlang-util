-module(socket_example).
%-import(lists,[reverse/1]).
-export([nano_get_url/0]).

nano_get_url()->
  nano_get_url("www.google.com").

nano_get_url(Host)->
  {ok,Socket}=gen_tcp:connect("www.baidu.com",80,[binary,{packet,0}]),
  ok=gen_tcp:send(Socket,"GET / HTTP/1.0\r\n\r\n"),
  receive_data(Socket,[]).

receive_data(Socket,SoFar)->
  receive
    {tcp,Socket,Bin}->
      receive_data(Socket,[Bin|SoFar]);
    {tcp_closed,Socket} ->
      list_to_binary(lists:reverse(SoFar))
  end.
  
  
%% 获取由函数 gen_tcp:listen/2 建立的套接字所监听的端口：
get_socket() ->
  {Rand, _RandSeed} = random:uniform_s(9999, erlang:now()),
  Port = 40000 + Rand,
  case gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]) of
     {ok, Socket} ->
       inet:port(Socket);
      _ -> 
        socket_listen_fail
    end.
  
%% 本服务所监听的端口：
%% get_socket() ->
%% Socket = util:get_socket(),
%% inet:port(Socket).