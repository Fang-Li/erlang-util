-module(monitor).
-compile(export_all).

%% monitor(Type, Item) -> MonitorRef
test() ->
  erlang:monitor(process, self()).

start() ->
  start(self()).

start(Proc) ->
  spawn(fun() ->
    erlang:monitor(process,Proc),
    receive
        {'DOWN',Ref,process,Pid,normal} ->
          io:format("~p said that ~p died by natural causes ~n",[Ref,Pid]);
        {'DOWN',Ref,process,Pid,Reason} ->
          io:format("~p said that ~p died by unnatural causes ~n~p~n",[Ref,Pid,Reason]);
        Exit ->
          io:format("xxx ~p~n",[Exit])
    end
  end).

reg() ->
  Pid = spawn(fun()->
      timer:sleep(5000),
      exit(0)
      end),
 erlang:register(pid,Pid).
  