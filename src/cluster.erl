-module(cluster).
-compile(export_all).

c1()->
  process_flag(trap_exit, true),
  Pid1=spawn_link(fun()->timer:sleep(10000) end),
  io:format("pid1 .. ~p~n",[Pid1]),
  Pid2=spawn_link(fun()->timer:sleep(10000) end),
  io:format("pid2 .. ~p~n",[Pid2]),
  receive
    {'DOWN', Ref, _, _, a} ->
        io:format("~p~n",[Ref]),
        Ref;
    {'DOWN', Ref, _, _, _} ->
        io:format("~p~n",[Ref]),
        Ref;
    {R,Ref,_,_,_} ->
        io:format("~p~n",[{R,Ref}]),
        {R,Ref};
    R->
        io:format("pid"),
        R
  end.

sup()->
    spawn_link(fun()->c1() end).