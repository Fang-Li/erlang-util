-module(simple_sup).
-compile(export_all).
-behaviour(supervisor).
start_link()->
  supervisor:start_link({local,?MODULE},?MODULE,[]).
init(_) ->
  {ok,{
    {simple_one_for_one,10,1},
    [{simple_sup,{simple_sup,restart,[]},permanent,brutal_kill,worker,[]}]
  }}.
restart() ->
  Pid = spawn_link(fun()-> 
    io:format("~p .. start ~n",[self()]),
    timer:sleep(10000),
    io:format("~p .. restart ~n",[self()])
     end),
  {ok,Pid}.

start_child()->
  supervisor:start_child(simple_sup,[]).