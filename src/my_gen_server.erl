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
handle_cast(bb,_State) ->
    %%A = "cast",
    io:format("A .. ~p~n",[bb]),
    {reply,[aa],[]};
handle_cast(Data,_State) ->
  %%A = "cast",
  io:format("A .. ~p~n",[Data]),
  {noreply,[]}.
handle_info(A,_) ->
  %A = "info",
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
  