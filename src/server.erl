-module(server).
-compile(export_all).
-behaviour(gen_server).

start(Args) ->
  %gen_server_module:start(gen_server_demo).
  gen_server:start( {local, server} ,server,[Args],[]),
  gen_server:start( {local, server1} ,server,[Args,extral],[]),
  gen_server:start( {local, server2} ,server,Args,[]).

init(Args) ->
  io:format("Args is .. ~p~n",[Args]),
  {ok,[]}.
handle_info(Req,_State) ->
  io:format("Requset is .. ~p",[Req]),
  {noreply,[]}.
handle_call(Req, _State) ->
  {a,[]}.
handle_cast(Req, _State) ->
  {cast,[]}.
