-module(gen_server_demo).
-compile(export_all).
-behaviour(gen_server_module).

start() ->
  gen_server_module:start(gen_server_demo).

init() ->
  {ok,[]}.
  
handle_call(Req, _State) ->
  {a,[]}.
handle_cast(Req, _State) ->
  {cast,[]}.
