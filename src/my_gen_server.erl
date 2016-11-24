-module(my_gen_server).
-compile(export_all).
-behaviour(gen_server).

start() ->
  gen_server:start( {local, proname} ,my_gen_server,[a],[]).
init(A) ->
  io:format("A .. ~p~n",[A]),
  {ok,[]}.
handle_call(_,_,_) ->
  A = "call",
  io:format("A .. ~p~n",[A]),
  {reply, hello, []}.
handle_cast(_,_) ->
  A = "cast",
  io:format("A .. ~p~n",[A]),
  {noreply,[]}.
handle_info(_,_) ->
  A = "info",
  io:format("A .. ~p~n",[A]),
  {noreply,[]}.
terminate(_,_) ->
  A = "terminate",
  io:format("A .. ~p~n",[A]),
  ok.
code_change(_,_,_) ->
  A = "code_change",
  io:format("A .. ~p~n",[A]),
  {ok,[]}.
  