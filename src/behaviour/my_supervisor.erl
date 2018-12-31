-module(my_supervisor).
-compile(export_all).

-behaviour(supervisor).
start() ->
  supervisor:start_link(my_supervisor,[]),
  supervisor:start_link(my_supervisor,[]).
  
init(_) ->
  {ok,{{one_for_one,1,1},
      [{tick,{my_supervisor,restart,[]},permanent,brutal_kill,worker,[]}]}}.

restart()->
  Pid = spawn_link(fun()->tick() end),
  {ok,Pid}.

tick() ->
  io:format("~p .. start~n",[self()]),
  timer:sleep(10000),
  io:format("~p .. quit~n",[self()]).

