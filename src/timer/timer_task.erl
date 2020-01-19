-module(timer_task).
-compile(export_all).
-behaviour(gen_server).
-define(TIMEOUT,2*1000).

start() ->
  gen_server:start( {local, ?MODULE} ,timer_task,[],[]).

init([]) ->
  {ok,[],?TIMEOUT}.

handle_call(_,_,_) ->
  {reply, [], []}.

handle_cast(_,_) ->
  {noreply,[]}.

handle_info(timeout,_) ->
  process_timer_task(),
  {noreply,[],?TIMEOUT}.

terminate(_,_) ->
  ok.

code_change(_,_,_) ->
  {ok,[]}.

process_timer_task()->
  io:format("start process timer message~n").